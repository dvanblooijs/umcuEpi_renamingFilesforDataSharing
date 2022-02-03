function renameFileContent(filename,key)
% this script checks the content of a more general file, like
% participants.tsv. This file does not contain a specific patient name in
% the filename, but might contain several names in the content of the file.
% This function removes original naming and replaces it with the naming
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

    % find all column names
    allFields = fieldnames(Variable);

    % check if any variable in each column contains the name that should be
    % replaced
    for i = 1:size(Variable,2)

        if iscellstr(Variable.(allFields{i})) %#ok<ISCLSTR>            
            for j = 1:size(Variable,1)
                if contains(Variable.(allFields{i}){j},origkey)
                    num = find(contains(origkey,Variable.(allFields{i}){j}) ==1);
                    Variable.(allFields{i}){j}= replace(Variable.(allFields{i}){j},origkey(num),renamekey(num));
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

    for j=1:size(origkey,1)
        indivkey = origkey{j}; renamekeyindiv = renamekey{j};
        Variable = renameStruct(Variable,indivkey,renamekeyindiv);
    end
    
    % save file
    write_json(filename, newVariable);
else
    warning('Variables in %s have not been renamed, since it is not added yet to function renameFileVar',nameExt)
end




end