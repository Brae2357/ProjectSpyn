classdef GyroController

    properties
        brick
        gyroPort
    end

    methods
        % Constructor
        function obj = GyroController(brick, gyroPort)
            obj.brick = brick;
            obj.gyroPort = gyroPort;
        end

        function calibrate(obj)
            obj.brick.GyroCalibrate(obj.gyroPort);
        end
    
        function angle = getAngle(obj)
            angle = -1 * obj.brick.GyroAngle(obj.gyroPort);
        end
    end
end