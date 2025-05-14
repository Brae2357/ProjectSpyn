classdef ColorScanner
    
    properties
        brick
        colorPort
    end

    methods
        % Constructor
        function obj = ColorScanner(brick, colorPort)
            obj.brick = brick;
            obj.colorPort = colorPort;
            bj.brick.SetColorMode(obj.colorPort, 4); % RGB mode
        end

        % Get RGB values in array {r, g, b}
        function rgbValues = getRGB(obj)
            rgbValues = obj.brick.ColorRGB(obj.colorPort);
        end

        % Get color character
        function colorCharacter = getColorCharacter(obj)
            if searchForColor(obj, 104, 14, 21, 10)
                colorCharacter = 'r'; % 'r' for red
            elseif searchForColor(obj, 15, 41, 37, 10)
                colorCharacter = 'g'; % 'g' for green
            elseif searchForColor(obj, 15, 34, 98, 10)
                colorCharacter = 'b'; % 'b' for blue
            else
                colorCharacter = 'n'; % 'n' for none
            end
        end

        % Get dominant primary color (returns 'r' 'g' 'b' or 'n' for none)
        function value = getDominantPrimaryColor(obj, minimumValue)
            rgbValues = getRGB(obj);

            redValue = rgbValues(1);
            greenValue = rgbValues(2);
            blueValue = rgbValues(3);

            if (redValue > greenValue) && (redValue > blueValue) && (redValue >= minimumValue)
                value = 'r';
            elseif (greenValue > redValue) && (greenValue > blueValue) && (blueValue >= minimumValue)
                value = 'g';
            elseif (blueValue > greenValue) && (blueValue > redValue) && (greenValue >= minimumValue)
                value = 'b';
            else
                value = 'n';
            end
        end

        % Return if a color is found within a certain threshold [0 to 255]
        % (1 for found, 0 for not found)
        function found = searchForColor(obj, redExpected, greenExpected, blueExpected, threshold)
            rgbValues = getRGB(obj);

            redValue = rgbValues(1);
            greenValue = rgbValues(2);
            blueValue = rgbValues(3);

            if (abs(redValue - redExpected) <= threshold) && (abs(greenValue - greenExpected) <= threshold) && (abs(blueValue - blueExpected) <= threshold)
                primaryColor = getDominantPrimaryColor(obj, 35);
                if redExpected >= greenExpected && redExpected >= blueExpected && primaryColor == 'r'
                    found = 1;
                elseif greenExpected >= redExpected && greenExpected >= blueExpected && primaryColor == 'g'
                    found = 1;
                elseif blueExpected >= greenExpected && blueExpected >= redExpected && primaryColor == 'b'
                    found = 1;
                else
                    found = 0;
                end
            else
                found = 0;
            end
        end
    end
end