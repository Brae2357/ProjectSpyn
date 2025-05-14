classdef BasicallyWaymoSettings < handle

    properties
        % Gyro Controller
        gyroPort
        
        % Engine
        engineRightMotor
        engineLeftMotor
        engineLiftMotor
        engineSpeed

        % Ultrasonic Scanner
        ultrasonicScannerMotorPort
        ultrasonicScannerPort
        ultrasonicScannerDegreesPerRotation
        ultrasonicScannerSpeed
        ultrasonicScannerRotationDirection

        % Color Scanner
        colorScannerPort

        % Maze Memorizer
        mmStartX
        mmStartY
        mmSafetyDistance
        mmCheckDistance
        mmPoiDistance
    end

    methods
        % Constructor
        function obj = BasicallyWaymoSettings(gyroPort, engineRightMotor, engineLeftMotor, engineLiftMotor, engineSpeed, ...
                                              ultrasonicScannerMotorPort, ultrasonicScannerPort, ultrasonicScannerDegreesPerRotation, ultrasonicScannerSpeed, ultrasonicScannerRotationDirection, ...
                                              colorScannerPort, ...
                                              mmStartX, mmStartY, mmSafetyDistance, mmCheckDistance, mmPoiDistance)
            % Gyro Controller
            obj.gyroPort = gyroPort;

            % Engine
            obj.engineRightMotor = engineRightMotor;
            obj.engineLeftMotor = engineLeftMotor;
            obj.engineLiftMotor = engineLiftMotor;
            obj.engineSpeed = engineSpeed;


            % Ultrasonic Scanner
            obj.ultrasonicScannerMotorPort = ultrasonicScannerMotorPort;
            obj.ultrasonicScannerPort = ultrasonicScannerPort;
            obj.ultrasonicScannerDegreesPerRotation = ultrasonicScannerDegreesPerRotation;
            obj.ultrasonicScannerSpeed = ultrasonicScannerSpeed;
            obj.ultrasonicScannerRotationDirection = ultrasonicScannerRotationDirection;

            % Color sensor
            obj.colorScannerPort = colorScannerPort;

            % Maze Memorizer
            obj.mmStartX = mmStartX;
            obj.mmStartY = mmStartY;
            obj.mmSafetyDistance = mmSafetyDistance;
            obj.mmCheckDistance = mmCheckDistance;
            obj.mmPoiDistance = mmPoiDistance;
        end
    end

    methods (Static)
        % Default settings
        function settings = BasicallyWaymoDefault()
            settings = BasicallyWaymoSettings(2, 'C', 'D', 'B', 40, ...
                                              'A', 1, 90, 10, 1, ...
                                              4, ...
                                              0, 0, 25, 65, 50);
        end
    end
end