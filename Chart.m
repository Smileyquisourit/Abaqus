classdef Chart
    %ABAQUES Represent an Abaque, in tabular form.
    %   Read an abaque in a CSV file and load it's content. Can interpolate
    % values of the table if needed.

    properties (Access=public)
        data table
    end

    properties (Dependent)
        col_names
    end

    methods % GET & SET
        function property = get.col_names(self)
            property = string(self.data.Properties.VariableNames);
        end
    end

    methods (Access=private)
        function [idx1,idx2] = get_surroudingLines(self,col,value,n)
            % NOTE: the last argument is there if a interpolation method
            % require more then 2 values (1 greater and one lower) to
            % interpolate a value.

            % Get slope:
            % ----------
            isAscending = self.data.(col)(1) < self.data.(col)(2);

            % Ascending case:
            % ---------------
            if isAscending
                if value < self.data.(col)(n)
                     error("Chart:ElementNotInChart", ...
                        "Value %d is lower than the first %d element of variable %s (%d)", ...
                        value,n,col,self.data.(col)(n))
                elseif value > self.data.(col)(end-(n-1))
                    error("Chart:ElementNotInChart", ...
                        "Value %d is greater than the last %d element of variable %s (%d)", ...
                        value,n,col,self.data.(col)(end))
                else
                    idx1 = find(self.data.(col) < value, 1, 'last');
                    idx2 = find(self.data.(col) > value, 1, 'first');
                end

            % Descending case:
            % ----------------
            else
                if value > self.data.(col)(n)
                     error("Chart:ElementNotInChart", ...
                        "Value %d is greater than the first %d element of variable %s (%d)", ...
                        value,n,col,self.data.(col)(n))
                elseif value < self.data.(col)(end-(n-1))
                    error("Chart:ElementNotInChart", ...
                        "Value %d is lower than the last %d element of variable %s (%d)", ...
                        value,n,col,self.data.(col)(end))
                else
                    idx1 = find(self.data.(col) > value, 1, 'last');
                    idx2 = find(self.data.(col) < value, 1, 'first');
                end
            end

            
            % % % % % Check range:
            % % % % % ------------
            % % % % if value < self.data.(col)(1)
            % % % %     error("Chart:ElementNotInChart", ...
            % % % %         "Value %d is lower than the first element of variable %s (%d)", ...
            % % % %         value,col,self.data.(col)(1))
            % % % % elseif value > self.data.(col)(end)
            % % % %     error("Chart:ElementNotInChart", ...
            % % % %         "Value %d is greater than the last element of variable %s (%d)", ...
            % % % %         value,col,self.data.(col)(end))
            % % % % end
            % % % % 
            % % % % % Iterate through the data:
            % % % % % -------------------------
            % % % % for ii = 1:1:numel(self.data.(col))-1
            % % % %     if value > self.data.(col)(ii) && value < self.data.(col)(ii+1)
            % % % %         idx1 = ii;
            % % % %         idx2 = ii+1;
            % % % %         break
            % % % %     end
            % % % % end
        end
        function result = interpolate_linear(self,x,from)
            [idx1,idx2] = self.get_surroudingLines(from,x,1);
            result = self.data(idx1,:) + ...
                (self.data{idx2,:}-self.data{idx1,:}) / ...
                (self.data{idx2,from}-self.data{idx1,from}) * ...
                (x-self.data{idx1,from});
        end
    end

    methods (Access=public)
        function obj = Chart(path,varargin)
        %ABAQUES Construct an instance of an abaque
        %   Read the CSV file at 'path' and loads it's content as a table

        % Check content
        if ~isfile(path)
            error("Chart:InvalidCSV","Invalid file !!")
        end
        
        obj.data = readtable(path,varargin{:,:});
        end

        function result = interpolate(self,x,options)
        %METHOD1 Interpolate a value from the abaque.
        %   This function enable the user to get a row from the abaque by
        % interpolating it if it isn't directly in it.
        arguments (Input)

            % Mandatory
            self
            x    (1,1) double

            % Optional
            options.variables (:,1) string = string.empty
            options.from      (:,1) string = string.empty
            options.as_table  (1,1) logical = false
            options.method    (1,1) string ...
                {mustBeMember(options.method,["linear"])} = "linear"
        end

        % Get the value from wich we should interpolate:
        % ----------------------------------------------
        if isempty(options.from)
            var_from = self.col_names(1);
        elseif numel(options.from) > 1
            error("Chart:TooManyVariables", ...
                "Too many variable from interpolate from !")
        elseif ~ismember(options.from,self.col_names)
            error("Chart:UnrecognizedVariable", ...
                "Unrecognized variable %s to interpolate from !", ...
                options.from)
        else
            var_from = options.from;
        end

        % Interpolate:
        % ------------
        if any(self.data.(var_from)==x)
            result_row = self.data(self.data.(var_from)==x,:);
        else
            switch options.method
                case "linear"
                    result_row = self.interpolate_linear(x,var_from);
            end
        end


        % Get only the wanted variables:
        % ------------------------------
        if isempty(options.variables)
            var_to = self.col_names;
        else
            for ii = 1:1:numel(options.variables)
                var_name = options.variables(ii);
                if ~ismember(var_name,self.col_names)
                    error("Chart:UnrecognizedVariable", ...
                        "Unrecognized variable name %s at position %d", ...
                        var_name,ii)
                end
            end
            var_to = options.variables;
        end
        result = result_row(:,var_to);

        % Convert to double if needed:
        % ----------------------------
        if ~options.as_table
            result = result{:,:};
        end
        
        end
    end
end