% A simple image rotator
% Copyright 2024 BenderBlog Rodriguez

classdef helperRotateImage < matlab.apps.AppBase
    
    % Properties that correspond to app components
    properties (Access = public)
        figure1  matlab.ui.Figure
        text9    matlab.ui.control.Label
        slider5  matlab.ui.control.Slider
        text3    matlab.ui.control.Label
        text2    matlab.ui.control.Label
        save     matlab.ui.control.Button
        g2       matlab.ui.control.UIAxes
        g1       matlab.ui.control.UIAxes
    end
    
    
    properties (Access = private)
        image,
        image_change,
        image_name,
        angle,
    end
    
    methods (Access = private)
        function deal_image_change(app)
            app.image_change = imrotate(app.image,app.angle);
            %app.image_change = imcrop(app.image_change,app.crop);
            imshow(app.image_change,'Parent',app.g2);
        end
        
        function save_return(app)
            r = centerCropWindow2d(size(app.image_change),[128 128]);
            imwrite(imcrop(app.image_change,r),app.image_name + "_dealt.jpg");
        end
    end
    
    
    % Callbacks that handle component events
    methods (Access = private)
        
        % Code that executes after component creation
        function Image_processing_GUI_OpeningFcn(app, image_array, image_name)
            % --- Executes just before Image_processing_GUI is made visible.
            % Ensure that the app appears on screen when run
            movegui(app.figure1, 'onscreen');
            app.image = image_array;
            app.image_name = image_name;
            app.angle = 0;
            
            imshow(app.image,'Parent',app.g1);
            
        end
        
        % Button pushed function: save
        function save_Callback(app, ~)
            disp("saving");
            save_return(app);
            delete(app);
        end
        
        % Value changed function: slider5
        function slider5_Callback(app, event)
            % --- Executes on slider movement.
            app.angle = event.Value;
            deal_image_change(app);
        end
        
        % Close request function: figure1
        function figure1CloseRequest(app, ~)
            delete(app)
        end
    end
    
    % Component initialization
    methods (Access = private)
        
        % Create UIFigure and components
        function createComponents(app)
            
            % Create figure1 and hide until all components are created
            app.figure1 = uifigure('Visible', 'off');
            app.figure1.Position = [1087 619 993 534];
            app.figure1.Name = 'Image_processing_GUI';
            app.figure1.Resize = 'off';
            app.figure1.CloseRequestFcn = createCallbackFcn(app, @figure1CloseRequest, true);
            app.figure1.HandleVisibility = 'callback';
            app.figure1.Tag = 'figure1';
            
            % Create g1
            app.g1 = uiaxes(app.figure1);
            app.g1.FontSize = 11;
            app.g1.NextPlot = 'replace';
            app.g1.Tag = 'g1';
            app.g1.Position = [98 91 380 405];
            
            % Create g2
            app.g2 = uiaxes(app.figure1);
            app.g2.FontSize = 11;
            app.g2.NextPlot = 'replace';
            app.g2.Tag = 'g2';
            app.g2.Position = [523 91 380 405];
            
            % Create save
            app.save = uibutton(app.figure1, 'push');
            app.save.ButtonPushedFcn = createCallbackFcn(app, @save_Callback, true);
            app.save.Tag = 'save';
            app.save.FontSize = 15;
            app.save.Position = [689 25 96 48];
            app.save.Text = '确认';
            
            % Create text2
            app.text2 = uilabel(app.figure1);
            app.text2.Tag = 'text2';
            app.text2.HorizontalAlignment = 'center';
            app.text2.WordWrap = 'on';
            app.text2.FontSize = 20;
            app.text2.FontColor = [1 0 0];
            app.text2.Position = [208 492 162.285714285714 40.8888888888889];
            app.text2.Text = '原始图片';
            
            % Create text3
            app.text3 = uilabel(app.figure1);
            app.text3.Tag = 'text3';
            app.text3.HorizontalAlignment = 'center';
            app.text3.WordWrap = 'on';
            app.text3.FontSize = 20;
            app.text3.FontColor = [1 0 0];
            app.text3.Position = [632 495 162.285714285714 34.6666666666666];
            app.text3.Text = '效果预览';
            
            % Create slider5
            app.slider5 = uislider(app.figure1);
            app.slider5.Limits = [-180 180];
            app.slider5.MajorTicks = [-180 -135 -90 -45 0 45 90 135 180];
            app.slider5.MajorTickLabels = {'-180', '-135', '-90', '-45', '0', '45', '90', '135', '180'};
            app.slider5.ValueChangedFcn = createCallbackFcn(app, @slider5_Callback, true);
            app.slider5.FontSize = 8;
            app.slider5.Tag = 'slider5';
            app.slider5.Position = [209 58 424 3];
            
            % Create text9
            app.text9 = uilabel(app.figure1);
            app.text9.Tag = 'text9';
            app.text9.HorizontalAlignment = 'center';
            app.text9.WordWrap = 'on';
            app.text9.Position = [128 33 48 32];
            app.text9.Text = '旋转';
            
            % Show the figure after all components are created
            app.figure1.Visible = 'on';
        end
    end
    
    % App creation and deletion
    methods (Access = public)
        
        % Construct app
        function app = helperRotateImage(varargin)
            
            % Create UIFigure and components
            createComponents(app)
            
            % Register the app with App Designer
            registerApp(app, app.figure1)
            
            % Execute the startup function
            runStartupFcn(app, @(app)Image_processing_GUI_OpeningFcn(app, varargin{:}))
            
            if nargout == 0
                clear app
            end
        end
        
        % Code that executes before app deletion
        function delete(app)
            
            % Delete UIFigure when app is deleted
            delete(app.figure1)
        end
    end
end