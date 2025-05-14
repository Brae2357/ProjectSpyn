classdef Controller

    properties
        engine
    end

    methods
        % Constructor
        function obj = Controller(engine)
            obj.engine = engine;
        end

        % Open keyboard controls
        function openController(obj)
            global key;
            Controller.InitKeyboard();

            while 1
                pause(0.1);
                % Find which key is being pressed
                switch key
                    case {'uparrow', 'w'}
                        obj.engine.forward();
                    case {'downarrow', 's'}
                        obj.engine.reverse();
                    case {'leftarrow', 'a'}
                        obj.engine.turnLeft();
                    case {'rightarrow', 'd'}
                        obj.engine.turnRight();
                    case {'return', 'e'}
                        obj.engine.liftUp();
                    case {'shift', 'q'}
                        obj.engine.liftDown();
                    case {'1', '2', '3', '4', '5', '6', '7', '8', '9'}
                        newSpeed = str2num(key) * 10;
                        obj.engine.setSpeed(newSpeed);
                    case '0'
                        obj.engine.setSpeed(100);
                    case 'space'
                        disp("Controller Closed");
                        break;
                    otherwise
                       obj.engine.stopMotors();
                end
            end
            Controller.CloseKeyboard();
        end
    end

    methods (Static)
        function InitKeyboard()
            global key
            global h
            key = 0;
            text(1) = {'Click on this window and press any key to control your robot.'};
            text(2) = {'The key currently being pressed is in the "key" variable.'};
            h = figure;
            set(h, 'KeyPressFcn', @(h_obj, evt) Controller.updateKey(evt.Key));
            set(h, 'KeyReleaseFcn', @(h_obj, evt) Controller.clearKey());
            textbox = annotation(h, 'textbox',[0,0,1,1]);
            set(textbox,'String', text);
        end

        function updateKey(eventKey)
            global key
            key = eventKey;
        end

        function clearKey
            global key
            key = 0;
        end

        function CloseKeyboard
            global h
            close(h);
        end
    end
end