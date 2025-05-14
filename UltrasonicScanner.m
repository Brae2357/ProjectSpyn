classdef UltrasonicScanner < handle

    properties
        brick
        motorPort
        scannerPort
        degreesPerRotation % 15 degrees recommended
        speed % 20 recommended
        rotationDirection % clockwise direction recommended for start (1 for clockwise, -1 for counterclockwise)
        % Rotation Direction is used to prevent the wire from getting
        % wrapped around the ultrasonic scanner
    end

    methods
        % Constructor
        function obj = UltrasonicScanner(brick, motorPort, scannerPort, degreesPerRotation, speed, rotationDirection)
            obj.brick = brick;
            obj.motorPort = motorPort;
            obj.scannerPort = scannerPort;
            obj.degreesPerRotation = degreesPerRotation;
            obj.speed = speed;
            obj.rotationDirection = rotationDirection;
        end

        % Get distance
        function distance = getDistance(obj)
            distance = obj.brick.UltrasonicDist(obj.scannerPort);
        end

        % Gets polar coordinates of surroundings
        function polarCoords = CalculateSurroundings(obj)
            % Create storage array (r, theta)
            polarCoords = zeros((360 / abs(obj.degreesPerRotation)), 2);

            % Reset camera motor
            obj.brick.ResetMotorAngle(obj.motorPort);
            obj.brick.WaitForMotor(obj.motorPort);
            
            % Rotate the sensor 360 degrees, stopping at each interval
            if mod(360,obj.degreesPerRotation) == 0
                for interval = 1:(360 / abs(obj.degreesPerRotation))
                    obj.brick.MoveMotorAngleRel(obj.motorPort, obj.speed, obj.rotationDirection * obj.degreesPerRotation, 'Brake');
                    obj.brick.WaitForMotor(obj.motorPort);

                    % Get distance
                    distance = obj.brick.UltrasonicDist(obj.scannerPort);

                    % Set polar coords
                    polarCoords(interval, 1) = distance; % r value
                    if obj.rotationDirection == 1
                        polarCoords(interval, 2) = interval * obj.degreesPerRotation; % theta value
                    else
                        polarCoords(interval, 2) = 360 - interval * obj.degreesPerRotation; % theta value
                    end

                    % Pause between each interval
                    pause(0.5);
                end
            end

            % Flip rotation direction
            obj = FlipRotationDirection(obj);
        end

        function obj = FlipRotationDirection(obj)
            obj.rotationDirection = -obj.rotationDirection;
        end

        function lookAround(obj)
            obj.brick.MoveMotorAngleRel(obj.motorPort, obj.speed, 360 * obj.rotationDirection, 'Brake');
            obj.brick.WaitForMotor(obj.motorPort);

            obj = FlipRotationDirection(obj);
        end
    end
end