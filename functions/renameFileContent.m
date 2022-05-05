function renameFileContent(filename,indivkey,renamekey,checkTRC)
% this script checks the content of each file, removes original naming and
% replaces it with the naming that is used for sharing data. 

% author: Dorien van Blooijs
% May 2021

%\\\ UPDATES \\\
% Eline Schaft - December 2021 - added trc files in this script
% Dorien van Blooijs - May 2022 - simplified script to make it less complex

[~,~, nameExt] = fileparts(filename);

% if it is a .tsv-file
if strcmp(nameExt,'.tsv')

    % load file
    Variable = readtable(filename,'FileType','text','Delimiter','\t');

    % find all column names (field names)
    allFields = Variable.Properties.VariableNames;

    % VARIABLE NAMES: check if any fieldname contains a name that should be renamed
    for jj = 1:size(allFields,2)
        for ii = 1:size(indivkey,1)
            if contains(allFields{jj},indivkey{ii})
                allFields{jj} = replace(allFields{jj},indivkey{ii},renamekey{ii});
                Variable.Properties.VariableNames{jj} = allFields{jj};
            end
        end
    end

    % VARIABLE CONTENT: check if any variable in each column contains the
    % name that should be replaced
    for jj = 1:size(Variable,2)
        for ii = 1:size(indivkey,1)
            if iscellstr(Variable.(allFields{jj})) %#ok<ISCLSTR>
                idx = contains(Variable.(allFields{jj}),indivkey{ii});
                Variable.(allFields{jj})(idx) = replace(Variable.(allFields{jj})(idx),indivkey{ii},renamekey{ii});
            end
        end
    end

    Variable = bids_tsv_nan2na(Variable);

    % save file
    writetable(Variable, filename, 'Delimiter', 'tab', 'FileType', 'text');% save file

elseif strcmp(nameExt,'.mat')

    % load file
    Variable = load(filename);

    % find all fields
    allFields = fieldnames(Variable);

    % VARIABLE CONTENT: check if any field contains the name that should be replaced
    for jj = 1:size(allFields,1)
        for ii = 1:size(indivkey,1)
            if  isstring(Variable.(allFields{jj})) || ischar(Variable.(allFields{jj}))

                Variable.(allFields{jj}) = replace(Variable.(allFields{jj}),indivkey{ii},renamekey{ii});

            elseif iscellstr(Variable.(allFields{jj}))
                idx = contains(Variable.(allFields{jj}),indivkey{ii});
                Variable.(allFields{jj})(idx) = replace(Variable.(allFields{jj})(idx),indivkey{ii},renamekey{ii});
            end
        end
    end

    % save file
    save(filename,'-struct','Variable')

elseif strcmp(nameExt,'.json')

     % load file
    Variable = read_json(filename);

    % check both VARIABLE NAMES and VARIABLE CONTENT
    newVariable = Variable;
    for ii = 1:size(indivkey,1)
        newVariable = renameStruct(newVariable,indivkey{ii},renamekey{ii});
    end

    % save file
    write_json(filename, newVariable);

elseif strcmp(nameExt,'.TRC') && checkTRC

    % load TRC
    [fid,~] = fopen(filename,'r+');

    % Find the original names
    fseek(fid,64,-1); subj_surname1   = fread(fid,22,'*char')';
    fseek(fid,86,-1); subj_name1   = fread(fid,20,'*char')';

    % Check whether subj_surname1 and subj_name1 are similar to the name in
    % the key
    if ~contains(subj_surname1,indivkey) || ~contains(subj_name1,indivkey)
        error('The TRC belongs to another patient. Check the name and identity of the TRC file.')
    end
    % Fill spaces of surname  and name with  blanks
    fseek(fid,64,-1); fwrite(fid,blanks(22),'char');
    fseek(fid,86,-1); fwrite(fid,blanks(20),'char');

    %fill with renamekey
    fseek(fid,64,-1); fwrite(fid,renamekey,'char');
    fseek(fid,86,-1); fwrite(fid,renamekey,'char');

    % Close the file (it will automatically be saved)
    fclose(fid);

else
    warning('Variables in %s have not been renamed, since it is not added yet to function renameFileContent',nameExt)
end

end