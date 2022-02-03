function names= unnest_fields(S, parent, names)
    % Function to list all the non-structure aka nested fields in a struct.
    if nargin<2; parent='S'; end % structure name... 
    if nargin<3; names= {}; end % names of all non-structure fields. 
    
    fields=fieldnames(S);
    for i=1:length(fields)
        new_parent=append(parent,'.',cellstr(fields{i}));
        
        if ~isa(S.(fields{i}),'struct') 
            % If this subfield isn't a structure then save "new_parent" to
            % the output list of un-nested field names. 
            names=vertcat(names,new_parent);
        else
            % Otherwise recursively look into this one... with "new_parent".
            names= unnest_fields(S.(fields{i}),new_parent, names);
        end
    end
end