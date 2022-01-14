function renameFileVar(filename,indivkey,renamekey,checkTRC)
% this script checks the content of each file, removes original naming and
% replaces it with the naming that is used for sharing data. 

% author: Dorien van Blooijs
% May 2021

%\\\ UPDATES \\\
% author: Eline Schaft
% December 2021
% added trc files in this script

[~,~, nameExt] = fileparts(filename);

% if it is a .tsv-file
if strcmp(nameExt,'.tsv')

    % load file
    Variable = readtable(filename,'FileType','text','Delimiter','\t');

    % find all column names
    allFields = fieldnames(Variable);

    % check if any variable in each column contains the name that should be
    % replaced
    for i = 1:size(Variable,2)

        if iscellstr(Variable.(allFields{i})) %#ok<ISCLSTR>

            idx = contains(Variable.(allFields{i}),indivkey);
            Variable.(allFields{i})(idx) = replace(Variable.(allFields{i})(idx),indivkey,renamekey);

        end
    end

    % save file
    writetable(Variable, filename, 'Delimiter', 'tab', 'FileType', 'text');

elseif strcmp(nameExt,'.mat')

    % load file
    Variable = load(filename);

    % find all fields
    allFields = fieldnames(Variable);

    % check if any field contains the name that should be replaced
    for i = 1:size(allFields,1)
        if  isstring(Variable.(allFields{i})) || ischar(Variable.(allFields{i}))

            Variable.(allFields{i}) = replace(Variable.(allFields{i}),indivkey,renamekey);

        elseif iscellstr(Variable.(allFields{i}))
            idx = contains(Variable.(allFields{i}),indivkey);
            Variable.(allFields{i})(idx) = replace(Variable.(allFields{i})(idx),indivkey,renamekey);
        end
    end

    % save file
    save(filename,'-struct','Variable')

elseif strcmp(nameExt,'.json')

     % load file
    Variable = read_json(filename);

    % find all fieldnames
    allFields = fieldnames(Variable);

    % check if any variable in each column contains the name that should be
    % replaced
    for i = 1:size(allFields,1)

        if isstruct(Variable.(allFields{i}))

            allsubFields = fieldnames(Variable.(allFields{i}));

            for j = 1:size(allsubFields,1) % if it is a double etc. , than it cannot contain the original name of the patient
                if isstring(Variable.(allFields{i}).(allsubFields{j}))
                    idx = contains(Variable.(allFields{i}).(allsubFields{j}),indivkey);
                    Variable.(allFields{i}).(allsubFields{j})(idx) = replace(Variable.(allFields{i}).(allsubFields{j})(idx),indivkey,renamekey);
                end
            end

        else

            if isstring(Variable.(allFields{i})) || ischar(Variable.(allFields{i})) % if it is a double etc. , than it cannot contain the original name of the patient
                idx = contains(Variable.(allFields{i}),indivkey);
                Variable.(allFields{i})(idx) = replace(Variable.(allFields{i})(idx),indivkey,renamekey);
            end
        end
    end

    % save file
    write_json(filename, Variable);

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
    warning('Variables in %s have not been renamed, since it is not added yet to function renameFileVar',nameExt)
end




end