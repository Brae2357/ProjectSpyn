classdef MazeMemorizer < handle
    
    properties
        engine
        gyroController
        ultrasonicScanner
        colorScanner
        controller

        startX
        startY
        currentX
        currentY

        safetyDistance % Distance car should stay away from wall
        checkDistance % Distance car should check for next POI (wall length)
        poiDistance % Distance needed to consider a point of interest (from current path)

        % Path Info
        currentPath
    end

    methods
        % Constructor
        function obj = MazeMemorizer(engine, gyroController, ultrasonicScanner, colorScanner, controller, startX, startY, safetyDistance, checkDistance, poiDistance)
            obj.engine = engine;
            
            obj.gyroController = gyroController;
            gyroController.calibrate(); % Calibrate gyro

            obj.ultrasonicScanner = ultrasonicScanner;

            obj.colorScanner = colorScanner;

            obj.controller = controller;

            obj.startX = startX;
            obj.startY = startY;
            obj.currentX = startX;
            obj.currentY = startY;

            obj.safetyDistance = safetyDistance;
            obj.checkDistance = checkDistance;
            obj.poiDistance = poiDistance;

            % 'S' for start position and 0 for no branch from start
            obj.currentPath = Path(startX, startY, 'S', 0, NaN);
        end

        function mapPath(obj)
            pathAngle = obj.currentPath.direction;
            obj.engine.rotateToGlobalAngle(pathAngle);
            obj.engine.resetOdometer();
            disp("Rotating to path angle");

            % Keep track of surronding scans (default 1)
            numOfSurroundingScans = 1;

            previousColor = 'n';
            previousOdometerReading = 0;
            runVehicle = true;
            obj.engine.forward();
            while runVehicle
                disp(obj.currentX + ", " + obj.currentY);
                odometer = obj.engine.odometer();
                colorCharacter = obj.colorScanner.getColorCharacter();
                distanceToEnd = obj.ultrasonicScanner.getDistance();
                checkCount = 0;
                while (distanceToEnd < obj.safetyDistance) && checkCount < 5
                    distanceToEnd = obj.ultrasonicScanner.getDistance();
                    checkCount = checkCount + 1;
                end

                % Update Position
                updatePosition(obj, odometer - previousOdometerReading, pathAngle);
                previousOdometerReading = odometer;

                if distanceToEnd < obj.safetyDistance
                    % End of path
                    obj.engine.stopMotors();

                    % Set end node
                    setEndNode(obj, odometer, colorCharacter);

                    % Check to make sure all POI nodes are pathed
                    % If not pathed, path them
                    % If all are pathed, go to start node
                    if ~isempty(obj.currentPath.poiNodes)
                        disp("Checking nodes...");
                        for i = numel(obj.currentPath.poiNodes):-1:1
                            pathLine = obj.currentPath.poiNodes{i};
                            pathLine = pathLine{4}.startNode{4};
                            if isempty(pathLine.endNode)
                                disp("Empty node found");
                                driveToNode(obj, pathLine.startNode);
                                oldPath = obj.currentPath;
                                obj.currentPath = pathLine;
                                mapPath(obj);
                                obj.currentPath = oldPath;
                            end
                        end
                    end
                    
                    disp("Driving back to start");
                    driveToNode(obj, obj.currentPath.startNode);
                    break;
                end

                % Color detection
                if (previousColor ~= 'r') && (colorCharacter == 'r')
                    previousColor = 'r';
                    foundRed(obj);
                    addEmptyPoiNode(obj, odometer, colorCharacter); % Add point of interest
                elseif (previousColor ~= 'g') && (colorCharacter == 'g')
                    foundGreen(obj);
                    break; % End automation (goal found)
                elseif (previousColor ~= 'b') && (colorCharacter == 'b')
                    foundBlue(obj);
                    setEndNode(obj, odometer, colorCharacter);
                    break; % End of path
                elseif obj.colorScanner.getDominantPrimaryColor(20) == 'n'
                    previousColor = 'n';
                end

                % Surrounding Scan
                if odometer >= obj.checkDistance * numOfSurroundingScans
                    obj.engine.stopMotors();
                    surroundings = obj.ultrasonicScanner.CalculateSurroundings();

                    for i = 1:size(surroundings, 1)
                        distanceFromPath = surroundings(i, 1) * sin(surroundings(i, 2) + obj.currentPath.direction);
                        if abs(distanceFromPath) >= obj.poiDistance
                            % Add point of interest
                            addPoiNode(obj, odometer, colorCharacter, mod(surroundings(i, 2) + obj.currentPath.direction, 360));
                        end
                    end

                    numOfSurroundingScans = numOfSurroundingScans + 1;
                    obj.engine.forward();
                end
            end

            obj.engine.stopMotors();
        end

        % Drive to node {x, y}
        function driveToNode(obj, node)
            disp("Driving to node: " + node{1} + ", " + node{2});
            pathAngle = obj.currentPath.direction;

            currentDistanceFromStart = sqrt(double((obj.currentPath.startNode{2} - obj.currentX)^2 + (obj.currentPath.startNode{1} - obj.currentY)^2));
            goalDistanceFromStart = sqrt(double((obj.currentPath.startNode{2} - node{1})^2 + (obj.currentPath.startNode{1} - node{2})^2));
            disp("Y: " + double(obj.currentX - node{1}));
            distance = abs(goalDistanceFromStart - currentDistanceFromStart);
            if goalDistanceFromStart < currentDistanceFromStart % Flip if it needs to go backwards
                pathAngle = pathAngle + 180;
            end
            obj.engine.rotateToGlobalAngle(pathAngle);

            disp("Driving distance: " + distance);
            obj.engine.drive(distance);
            updatePosition(obj, distance, pathAngle);
        end

        function addEmptyPoiNode(obj, odometer, colorCharacter)
            xPosition = abs(obj.currentPath.startNode{1} + (odometer * sin(deg2rad(obj.currentPath.direction))));
            yPosition = abs(obj.currentPath.startNode{2} + (odometer * cos(deg2rad(obj.currentPath.direction))));
            newPath = Path(xPosition, yPosition, colorCharacter, 0, obj.currentPath); % null path for no connecting path
            obj.currentPath.addPoiNode(xPosition, yPosition, colorCharacter, newPath);
        end

        % add POI with connecting path
        function newPath = addPoiNode(obj, odometer, colorCharacter, globalAngle)
            globalAngle = globalAngle + 90;
            disp("Node added -> Global angle: " + globalAngle);
            xPosition = abs(obj.currentPath.startNode{1} + (odometer * sin(deg2rad(globalAngle))));
            yPosition = abs(obj.currentPath.startNode{2} + (odometer * cos(deg2rad(globalAngle))));
            newPath = Path(xPosition, yPosition, colorCharacter, globalAngle, obj.currentPath);
            disp(newPath.direction);
            obj.currentPath.addPoiNode(xPosition, yPosition, colorCharacter, newPath);
        end

        function setEndNode(obj, odometer, colorCharacter)
            disp("Setting end node");
            xPosition = abs(obj.currentPath.startNode{1} + (odometer * sin(deg2rad(obj.currentPath.direction))));
            yPosition = abs(obj.currentPath.startNode{2} + (odometer * cos(deg2rad(obj.currentPath.direction))));
            
            newPath = Path(xPosition, yPosition, colorCharacter, 0, obj.currentPath); % null path for no connecting path
            obj.currentPath.setEndNode(xPosition, yPosition, colorCharacter, newPath);  
        end

        function foundRed(obj)
            disp("Found red");
            obj.engine.stopMotors();
            pause(0.5);
            obj.ultrasonicScanner.lookAround();
            pause(0.5);
            obj.engine.forward();
        end

        function foundGreen(obj)
            disp("Found green");
            obj.engine.stopMotors();
            obj.controller.openController();
        end

        function foundBlue(obj)
            disp("Found blue");
            enterAngle = obj.gyroController.getAngle();
            obj.engine.stopMotors();
            obj.controller.openController();
            % Turn car around and continue driving
            currentAngle = obj.gyroController.getAngle();
            obj.engine.rotateVehicle(enterAngle - currentAngle + 180, 0.3);
        end
        
        % Update position of car moving forward (uses angle to know x and y)
        function updatePosition(obj, distanceForward, angle)
            % Convert angle to radians
            angleRad = deg2rad(angle);
        
            % Calculate the change in position
            deltaX = distanceForward * cos(angleRad); % Change in x (positive for 90 degrees)
            deltaY = distanceForward * sin(angleRad); % Change in y (positive for 0 degrees)
        
            % Update the current position
            obj.currentX = obj.currentX + deltaX;
            obj.currentY = obj.currentY + deltaY;
        end

        % Find points where there could be another path
        function searchForPOI(obj)
            disp("Searching for POIs");
            % Get the surroundings in polar coordinates [r, theta]
            surroundings = obj.ultrasonicScanner.CalculateSurroundings();
        
            % Iterate through each point in the surroundings
            for i = 1:size(surroundings, 1)
                r = surroundings(i, 1);      % Radius (distance to the point)
                theta = deg2rad(surroundings(i, 2));  % Angle in radians
        
                % Calculate the perpendicular component
                verticalDistance = sin(theta) * r;
        
                % Check if it meets the poiDistance threshold
                if abs(verticalDistance) >= obj.poiDistance
                    % Found a POI
                    globalDirection = mod(theta + obj.gyroController.getAngle(), 360);
                    obj.currentPath.addPoiNode(obj.currentX, obj.currentY, r, globalDirection);

                    % TEMPORARY
                    disp("Found point of interest");
                end
            end
        end
    end
end