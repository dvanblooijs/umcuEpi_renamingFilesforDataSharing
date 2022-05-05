function newVariable = renameStruct(Variable,indivkey,renamekey)

% this function:
% - finds all fieldnames
% - checks whether a fieldname contains any name that should be renamed
%   before sharing the data externally
% - checks whether the content contains any name that should be renamed

% find all fieldnames
fieldNames = unnest_fields(Variable, 'Variable');

% VARIABLE NAMES: check fieldnames
if any(contains(fieldNames,indivkey))
    newVariable = struct();

    % run through all fieldnames
    for ii = 1:size(fieldNames,1)

        fieldparts = strsplit(fieldNames{ii},'.');

        if contains(fieldNames{ii},indivkey)
            newname = replace(fieldNames{ii},indivkey,renamekey);
            fieldpartsnew = strsplit(newname,'.');
            newVariable = setfield(newVariable,fieldpartsnew{2:end},getfield(Variable,fieldparts{2:end}));
        else
            newVariable = setfield(newVariable,fieldparts{2:end},getfield(Variable,fieldparts{2:end}));
        end
    end
else
    newVariable = Variable;
end

% VARIABLE CONTENT: check content of fieldnames in struct
for ii = 1:size(fieldNames,1)

    fieldparts = strsplit(fieldNames{ii},'.');

    if isstring(getfield(Variable,fieldparts{2:end})) || ischar(getfield(Variable,fieldparts{2:end}))
        if any(contains(getfield(Variable,fieldparts{2:end}),indivkey))

            newname = replace(getfield(Variable,fieldparts{2:end}),indivkey,renamekey);
            newVariable = setfield(Variable,fieldparts{2:end},newname);
        end
    end
end

