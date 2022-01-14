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

    % save file
    writetable(Variable, filename, 'Delimiter', 'tab', 'FileType', 'text');

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
                if isstring(Variable.(allFields{i}).(allsubFields{j})) || ischar(Variable.(allFields{i}).(allsubFields{j}))
                    num = find(contains(origkey,Variable.(allFields{i}).(allsubFields{j}))==1);
                    Variable.(allFields{i}).(allsubFields{j}) = replace(Variable.(allFields{i}).(allsubFields{j}),origkey(num),renamekey(num));
                end
            end

        else

            if isstring(Variable.(allFields{i})) || ischar(Variable.(allFields{i}))% if it is a double etc. , than it cannot contain the original name of the patient
                num = find(contains(origkey,Variable.(allFields{i}))==1);
                Variable.(allFields{i}) = replace(Variable.(allFields{i}),origkey(num),renamekey(num));
           
            elseif iscell(Variable.(allFields{i}))
                for j = 1:size(Variable.(allFields{i}),2)
                    num = find(contains(origkey,Variable.(allFields{i}){j})==1);
                    Variable.(allFields{i}){j} = replace(Variable.(allFields{i}){j},origkey(num),renamekey(num));
                end
            end
        end
    end

    % save file
    write_json(filename, Variable);
    
else
    warning('Variables in %s have not been renamed, since it is not added yet to function renameFileVar',nameExt)
end




end