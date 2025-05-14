classdef BasicallyWaymo < handle

    properties
        brick
        settings

        % Components
        gyroController
        engine
        controller
        ultrasonicScanner
        colorScanner
        mazeMemorizer

        % Destination variables
        startColor
        pickupColor
        destinationColor
    end

    methods
        % Constructor
        function obj = BasicallyWaymo(brick, settings)
            obj.brick = brick;
            obj.settings = settings;

            % Create Gyro Controller
            obj.gyroController = GyroController(brick, settings.gyroPort);

            % Create Engine
            obj.engine = Engine(brick, settings.engineRightMotor, settings.engineLeftMotor, settings.engineLiftMotor, settings.engineSpeed, obj.gyroController);

            % Create Controller
            obj.controller = Controller(obj.engine);

            % Create Ultrasonic Scanner
            obj.ultrasonicScanner = UltrasonicScanner(brick, settings.ultrasonicScannerMotorPort, settings.ultrasonicScannerPort, settings.ultrasonicScannerDegreesPerRotation, settings.ultrasonicScannerSpeed, settings.ultrasonicScannerRotationDirection);

            % Create Color Scanner
            obj.colorScanner = ColorScanner(brick, settings.colorScannerPort);

            % Create Maze Memorizer
            obj.mazeMemorizer = MazeMemorizer(obj.engine, obj.gyroController, obj.ultrasonicScanner, obj.colorScanner, obj.controller, settings.mmStartX, settings.mmStartY, settings.mmSafetyDistance, settings.mmCheckDistance, settings.mmPoiDistance);
        end

        % Start Bwaymo
        function activate(obj)
            % Welcome user
            BasicallyWaymo.welcomeUser();
            autonomous(obj);

            % Say goodbye to user
            BasicallyWaymo.farewellUser();
        end

        % Autonomous mode
        function autonomous(obj)
            obj.mazeMemorizer.mapPath();
        end

        function stopCar(obj)
            obj.engine.stopMotors();
        end
    end

    methods (Static)
        % Bwaymo welcome
        function welcomeUser()
            disp("Welcome user!");

            %writeStatusLight(brick, 'blue', 'solid');
            pause(1);
        end

        % Bwaymo goodbye
        function farewellUser()
            disp("Goodbye! (for now...)");

            %writeStatusLight(brick, 'purple', 'solid');
            pause(1);
        end
    end
end