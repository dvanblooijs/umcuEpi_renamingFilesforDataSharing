function renameFileVar(filename,indivkey,renamekey)
% author: Dorien van Blooijs
% May 2021

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
    
else
    warning('Variables in %s have not been renamed, since it is not added yet')
end




end