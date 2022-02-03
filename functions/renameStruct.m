
function newVariable = renameStruct(Variable,indivkey,renamekey)
    % find all fieldnames
    fieldNames = unnest_fields(Variable, 'Variable');

    % check content of fieldnames in struct
    for i = 1:size(fieldNames,1)

        fieldparts = strsplit(fieldNames{i},'.');

        if isstring(getfield(Variable,fieldparts{2:end})) || ischar(getfield(Variable,fieldparts{2:end}))
            if any(contains(getfield(Variable,fieldparts{2:end}),indivkey))

                newname = replace(getfield(Variable,fieldparts{2:end}),indivkey,renamekey);
                Variable = setfield(Variable,fieldparts{2:end},newname);
            end
        end
    end

    % check fieldnames
    if any(contains(fieldNames,indivkey))
        newVariable = struct();
        for i = 1:size(fieldNames,1)

            fieldparts = strsplit(fieldNames{i},'.');

            if contains(fieldNames{i},indivkey)
                newname = replace(fieldNames{i},indivkey,renamekey);
                fieldpartsnew = strsplit(newname,'.');
                newVariable = setfield(newVariable,fieldpartsnew{2:end},getfield(Variable,fieldparts{2:end}));
            else
                newVariable = setfield(newVariable,fieldparts{2:end},getfield(Variable,fieldparts{2:end}));
            end
        end
    else
        newVariable = Variable;

    end