classdef Engine < handle
    
    properties
        brick
        rightMotor
        leftMotor
        liftMotor
        speed
        gyroController
    end

    methods
        % Constructor
        function obj = Engine(brick, rightMotor, leftMotor, liftMotor, speed, gyroController)
            obj.brick = brick;
            obj.rightMotor = rightMotor;
            obj.leftMotor = leftMotor;
            obj.liftMotor = liftMotor;
            obj.speed = speed;
            obj.gyroController = gyroController;
        end

        % Drive car forward by distance (in cm)
        function drive(obj, distance)
            % Calculate wheel circumference
            wheelCircumference = pi * 5.8; % 5.8 is wheel diameter
            
            % Calculate the required motor rotation amount in degrees
            rotationAmount = (distance / wheelCircumference) * 360;
            
            % Move the motors based on calculated rotation
            obj.brick.MoveMotorAngleRel(obj.leftMotor, obj.speed, -rotationAmount, 'Brake');
            obj.brick.MoveMotorAngleRel(obj.rightMotor, obj.speed, -rotationAmount, 'Brake');
            
            % Wait for both motors to complete their movement
            obj.brick.WaitForMotor(obj.leftMotor);
            obj.brick.WaitForMotor(obj.rightMotor);
        end
        
        % Forward direction
        function forward(obj)
            obj.brick.MoveMotor(obj.leftMotor, -(obj.speed));
            obj.brick.MoveMotor(obj.rightMotor, -(obj.speed));
        end

        % Reverse direction
        function reverse(obj)
            obj.brick.MoveMotor(obj.leftMotor, obj.speed);
            obj.brick.MoveMotor(obj.rightMotor, obj.speed);
        end

        % Right turn
        function turnRight(obj)
            obj.brick.MoveMotor(obj.leftMotor, -(obj.speed));
            obj.brick.MoveMotor(obj.rightMotor, obj.speed);
        end

        % Left turn
        function turnLeft(obj)
            obj.brick.MoveMotor(obj.leftMotor, obj.speed);
            obj.brick.MoveMotor(obj.rightMotor, -(obj.speed));
        end

        % Lift up
        function liftUp(obj)
            obj.brick.MoveMotor(obj.liftMotor, -(obj.speed));
        end

        % Lift down
        function liftDown(obj)
            obj.brick.MoveMotor(obj.liftMotor, obj.speed);
        end

        % Stop motors
        function stopMotors(obj)
            obj.brick.MoveMotor(obj.leftMotor, 0);
            obj.brick.MoveMotor(obj.rightMotor, 0);
            obj.brick.MoveMotor(obj.liftMotor, 0);
        end

        function setSpeed(obj, speed)
            if speed ~= obj.speed
                obj.speed = speed;
                disp("Engine speed changed to " + speed);
            end
        end

        % Reset odometer
        function resetOdometer(obj)
            obj.brick.ResetMotorAngle(obj.rightMotor);
            obj.brick.ResetMotorAngle(obj.leftMotor);
        end

        % Get distance driven since last reset
        function distance = odometer(obj)
            % Calculate wheel circumference
            wheelCircumference = pi * 5.8; % 5.8 is wheel diameter

            % Get rotation amount of motor in degrees
            degrees = obj.brick.GetMotorAngle(obj.rightMotor);

            distance = wheelCircumference * (degrees / -360);
        end

        % Turn vehicle to global angle [0 to 360]
        function rotateToGlobalAngle(obj, targetAngle)
            % Get the current angle from the gyro sensor
            currentAngle = obj.gyroController.getAngle();
            
            % Calculate the shortest angle difference (-180 to 180 range)
            angleDifference = mod(targetAngle - currentAngle + 180, 360) - 180;
            
            % Rotate the vehicle by the calculated angle difference
            rotateVehicle(obj, angleDifference, 0.3);
        end

        % Turn the vehicle by degree amount [-180 to 180]
        function rotateVehicle(obj, degrees, threshold)
            defaultSpeed = obj.speed;
            obj.speed = 20; % Slow down turn
            degrees = mod(degrees, 360);
            goalAngle = mod(obj.gyroController.getAngle() + degrees, 360);

            % Calculate the angle difference in the range [-180, 180]
            angleDifference = mod(goalAngle - obj.gyroController.getAngle() + 180, 360) - 180;

            % Positive for clockwise, negative for counterclockwise
            while abs(angleDifference) > threshold
                % Update angleDifference in the loop
                currentAngle = obj.gyroController.getAngle();
                angleDifference = mod(goalAngle - currentAngle + 180, 360) - 180;
        
                % Implement movement logic here based on angleDifference
                % For example, rotate clockwise or counterclockwise
                if angleDifference > threshold
                    % Rotate clockwise
                    turnRight(obj);
                elseif angleDifference < -threshold
                    % Rotate counterclockwise
                    turnLeft(obj);
                else
                    stopMotors(obj);
                end

                if abs(angleDifference) <= 5
                    obj.speed = 8; % Very slow down turn
                elseif abs(angleDifference) <= 20
                    obj.speed = 12; % Slow turn
                end
        
                pause(0.1);
            end
        
            % Stop motors after reaching the goal
            stopMotors(obj);

            % Reset speed
            obj.speed = defaultSpeed;
        end
    end
end