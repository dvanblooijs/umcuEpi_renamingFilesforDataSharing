function renameFileContent(filename,key)
% this script checks the content of a more general file, like
% participants.tsv, dataset_description.json, scans.json etc. This file
% does not contain a specific patient name in the filename, but might
% contain several names in the content of the file. This function removes
% original naming and replaces it with the naming
% that is used for sharing data.

% author: Dorien van Blooijs
% January 2022

[~,~, nameExt] = fileparts(filename);
origkey = key(:,1);
renamekey = key(:,2);

% if it is a .tsv-file
if strcmp(nameExt,'.tsv')

    % load file
    Variable = readtable(filename,'FileType','text','Delimiter','\t');

    % find all column names (field names)
    allFields = Variable.Properties.VariableNames;

    % VARIABLE NAMES: check if any fieldname contains a name that should be renamed
    for jj = 1:size(allFields,2)
        for ii = 1:size(origkey,1)
            if contains(origkey{ii},allFields{jj})
                allFields{jj} = replace(allFields{jj},origkey{ii},renamekey{ii});
                Variable.Properties.VariableNames{jj} = allFields{jj};
            end
        end
    end

    % VARIABLE CONTENT: check if any variable in each column contains a name that should be
    % renamed
    for ii = 1:size(Variable,2)

        if iscellstr(Variable.(allFields{ii})) %#ok<ISCLSTR>            
            for jj = 1:size(Variable,1)
                if contains(Variable.(allFields{ii}){jj},origkey)
                    num = find(contains(origkey,Variable.(allFields{ii}){jj}) ==1);
                    Variable.(allFields{ii}){jj}= replace(Variable.(allFields{ii}){jj},origkey(num),renamekey(num));
                end
            end
        end
    end

    Variable = bids_tsv_nan2na(Variable);

    % save file
    writetable(Variable, filename, 'Delimiter', 'tab', 'FileType', 'text');

elseif strcmp(nameExt,'.json')

    % load file
    Variable = read_json(filename);

    % for each key, check whether it is present in this specific json-file
    for jj = 1:size(origkey,1)
        indivkey = origkey{jj}; renamekeyindiv = renamekey{jj};
        
        % check both variable names and variable content
        Variable = renameStruct(Variable,indivkey,renamekeyindiv);
    end
    
    % save file
    write_json(filename, Variable);

else
    warning('Variables in %s have not been renamed, since it is not added yet to function renameFileVar',nameExt)
end

end