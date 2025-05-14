classdef Path < handle

    properties
        % color is set to 'N' for null object
        startNode % [x, y, color, line]
        endNode   % [x, y, color, line]
        direction % Angle from start to end node relative to start angle
        poiNodes  % [x, y, color, line]
    end

    methods
        % Constructor (connecting line should be the line its coming from)
        function obj = Path(xStart, yStart, color, angleOfPath, connectingLine)
            obj.startNode = {xStart, yStart, color, connectingLine};
            obj.endNode = {};
            obj.direction = angleOfPath;
            obj.poiNodes = {};
        end

        % Set end node (following line should be the line (if any) that it goes to next)
        function setEndNode(obj, xPosition, yPosition, color, followingLine)
            obj.endNode = {xPosition, yPosition, color, followingLine};
        end

        % Add POI
        function newPOI = addPoiNode(obj, xPosition, yPosition, color, lineBranch)
            newPOI = {xPosition, yPosition, color, Path(xPosition, yPosition, color, obj.direction, lineBranch)};
            if isempty(obj.poiNodes)
                obj.poiNodes = {newPOI};  % Initialize as a cell array of cells
            else
                obj.poiNodes{end + 1} = newPOI;  % Append to the cell array
            end
        end
    end
end