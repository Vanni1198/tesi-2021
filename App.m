classdef rssid < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                      matlab.ui.Figure
        UITable                       matlab.ui.control.Table
        LoadButton                    matlab.ui.control.Button
        PlotButton                    matlab.ui.control.Button
        TypeofFittingDropDownLabel    matlab.ui.control.Label
        TypeofFittingDropDown         matlab.ui.control.DropDown
        CButton                       matlab.ui.control.Button
        WRNEditField                  matlab.ui.control.EditField
        Panel                         matlab.ui.container.Panel
        ModelTextAreaLabel            matlab.ui.control.Label
        ModelTextArea                 matlab.ui.control.TextArea
        fTextArea                     matlab.ui.control.TextArea
        CoefficientsTextAreaLabel     matlab.ui.control.Label
        CoefficientsTextArea          matlab.ui.control.TextArea
        R2EditFieldLabel              matlab.ui.control.Label
        R2EditField                   matlab.ui.control.NumericEditField
        RMSEEditFieldLabel            matlab.ui.control.Label
        RMSEEditField                 matlab.ui.control.NumericEditField
        SSEEditFieldLabel             matlab.ui.control.Label
        SSEEditField                  matlab.ui.control.NumericEditField
        Image                         matlab.ui.control.Image
        HowtoUseLabel                 matlab.ui.control.Label
        PressLoadandopenacvsfileformedbytowcolumsofdataLabel  matlab.ui.control.Label
        CurveFittingApplicationLabel  matlab.ui.control.Label
        UIAxes                        matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        %Funzione per importare i dati, non ha input, in output restituisce
        %una matrice (2xn)
        function [array_of_data, raw_data] = Load_Data(app)
            [filename, pathname]= uigetfile('.csv','File Selector');
            fullpathname=strcat(pathname,filename); 
            raw_data=importdata(fullpathname); 
            array_of_data=raw_data.data; 
        end
        
        %Funzione per scegliere il tipo di fitting, prende in input la
        %selezione da menu, e restituisce fitform, per il print nella text
        %area, e type_of_fit da inserire nel comando fit
        function [fitform, type_of_fit] = Type_of_Fit(app)
            type_of_fit_dd=app.TypeofFittingDropDown.Value;
            type_of_fit_s=string(type_of_fit_dd);
            if type_of_fit_s=="Linear"
                type_of_fit='poly1';
                fitform='Linear';
            elseif type_of_fit_s=='Quadratic'
                type_of_fit='poly2';
                fitform='Quadratic';
            elseif type_of_fit_s=='Cubic'
                type_of_fit='poly3';
                fitform='Cubic';
            elseif type_of_fit_s=='Power'
                type_of_fit='power1';
                fitform='Power';
            elseif type_of_fit_s=='Exponential'
                type_of_fit='exp1';
                fitform='Exponential';
            end
        end

        %Pulisce l'app, cancella grafici, scritte e dati
        function Clear_all(app)
            cla(app.UIAxes);
            app.fTextArea.Value='';
            app.CoefficientsTextArea.Value='';
            app.UITable.Data=[]; 
            app.WRNEditField.Value='';
            app.ModelTextArea.Value='';
            app.R2EditField.Value=0;
            app.RMSEEditField.Value=0;
            app.SSEEditField.Value=0;
        end
        %Prende i nomi delle colonne dai dati estratti dalla tabella in .cvs
        function [Name_1, Name_2] = Extrac_Name(~,raw_data)
            name_1=raw_data.textdata(1);
            Name_1=string(name_1);
            name_2=raw_data.textdata(2);
            Name_2=string(name_2);
        end
        
        %Effettua il fit, e ne restituisce i parametri
        function [f, fitform, Fit_Param, d, RSSI] = Fitting_Func(app)
                d=app.UITable.Data(:,1);
                RSSI=app.UITable.Data(:,2);
                [fitform, type_of_fit]=Type_of_Fit(app);       
                [f,Fit_Param]=fit(RSSI,d,type_of_fit);
            
        end
        
        %Fa il plot sul grafico
        function Plot_Func(app, f, RSSI, d)
                fitted_vector=feval(f,RSSI);   
                plot(app.UIAxes,RSSI,fitted_vector,"Color",'black',"LineWidth",1.5);
                hold(app.UIAxes,'on');
                stem(app.UIAxes,RSSI,d,'filled','LineStyle','none','MarkerEdgeColor','b');             
        end
        
        %Scrive nelle aree i valori di interesse
        function Write_Func(app, f, fitform, Fit_Param)
                fun=formula(f);
                coef=coeffvalues(f);
                app.ModelTextArea.Value= fitform;
                app.fTextArea.Value= fun;
                coef_s=num2str(coef);
                app.CoefficientsTextArea.Value=coef_s;
                app.R2EditField.Value=Fit_Param.rsquare;
                app.RMSEEditField.Value=Fit_Param.rmse;
                app.SSEEditField.Value=Fit_Param.sse;
                
            
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: LoadButton
        function LoadButtonPushed(app, event)
            [array_of_data, raw_data]=Load_Data(app);
            [Name_1, Name_2]=Extrac_Name(app,raw_data);
            app.UITable.Data=array_of_data; %inserisce i dati nella tabella           
            app.UITable.ColumnName=[Name_1; Name_2]; %Nomina le colonne della tabella
            app.UIAxes.YLabel.String=Name_1;
            app.UIAxes.XLabel.String=Name_2;
        end

        % Button pushed function: PlotButton
        function PlotButtonPushed(app, event)
            if isempty(app.UITable.Data)==1 
                
                app.WRNEditField.Value='Please Load Data';
                
            else
                
                [f, fitform, Fit_Param, d, RSSI] = Fitting_Func(app);
                Plot_Func(app, f, RSSI, d);
                Write_Func(app, f, fitform, Fit_Param);

            end
        end

        % Button pushed function: CButton
        function CButtonPushed(app, event)
            Clear_all(app);
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Color = [0.9412 0.9412 0.9412];
            app.UIFigure.Position = [100 100 880 497];
            app.UIFigure.Name = 'MATLAB App';

            % Create UITable
            app.UITable = uitable(app.UIFigure);
            app.UITable.ColumnName = {'.'; '.'};
            app.UITable.RowName = {};
            app.UITable.Position = [686 19 164 185];

            % Create LoadButton
            app.LoadButton = uibutton(app.UIFigure, 'push');
            app.LoadButton.ButtonPushedFcn = createCallbackFcn(app, @LoadButtonPushed, true);
            app.LoadButton.Position = [140 328 100 22];
            app.LoadButton.Text = 'Load';

            % Create PlotButton
            app.PlotButton = uibutton(app.UIFigure, 'push');
            app.PlotButton.ButtonPushedFcn = createCallbackFcn(app, @PlotButtonPushed, true);
            app.PlotButton.Position = [407 170 100 22];
            app.PlotButton.Text = 'Plot';

            % Create TypeofFittingDropDownLabel
            app.TypeofFittingDropDownLabel = uilabel(app.UIFigure);
            app.TypeofFittingDropDownLabel.HorizontalAlignment = 'right';
            app.TypeofFittingDropDownLabel.Position = [27 278 81 22];
            app.TypeofFittingDropDownLabel.Text = 'Type of Fitting';

            % Create TypeofFittingDropDown
            app.TypeofFittingDropDown = uidropdown(app.UIFigure);
            app.TypeofFittingDropDown.Items = {'Linear', 'Quadratic', 'Cubic', 'Power', 'Exponential'};
            app.TypeofFittingDropDown.Position = [123 278 133 22];
            app.TypeofFittingDropDown.Value = 'Linear';

            % Create CButton
            app.CButton = uibutton(app.UIFigure, 'push');
            app.CButton.ButtonPushedFcn = createCallbackFcn(app, @CButtonPushed, true);
            app.CButton.Position = [565 170 25 22];
            app.CButton.Text = 'C';

            % Create WRNEditField
            app.WRNEditField = uieditfield(app.UIFigure, 'text');
            app.WRNEditField.Position = [27 19 248 22];

            % Create Panel
            app.Panel = uipanel(app.UIFigure);
            app.Panel.BackgroundColor = [0.9412 0.9412 0.9412];
            app.Panel.Position = [27 58 248 199];

            % Create ModelTextAreaLabel
            app.ModelTextAreaLabel = uilabel(app.Panel);
            app.ModelTextAreaLabel.HorizontalAlignment = 'right';
            app.ModelTextAreaLabel.Position = [26 160 38 22];
            app.ModelTextAreaLabel.Text = 'Model';

            % Create ModelTextArea
            app.ModelTextArea = uitextarea(app.Panel);
            app.ModelTextArea.Position = [79 158 150 26];

            % Create fTextArea
            app.fTextArea = uitextarea(app.Panel);
            app.fTextArea.Position = [79 122 150 37];

            % Create CoefficientsTextAreaLabel
            app.CoefficientsTextAreaLabel = uilabel(app.Panel);
            app.CoefficientsTextAreaLabel.HorizontalAlignment = 'right';
            app.CoefficientsTextAreaLabel.Position = [7 94 68 22];
            app.CoefficientsTextAreaLabel.Text = 'Coefficients';

            % Create CoefficientsTextArea
            app.CoefficientsTextArea = uitextarea(app.Panel);
            app.CoefficientsTextArea.Position = [79 88 150 35];

            % Create R2EditFieldLabel
            app.R2EditFieldLabel = uilabel(app.Panel);
            app.R2EditFieldLabel.HorizontalAlignment = 'right';
            app.R2EditFieldLabel.Position = [62 54 26 22];
            app.R2EditFieldLabel.Text = 'R^2';

            % Create R2EditField
            app.R2EditField = uieditfield(app.Panel, 'numeric');
            app.R2EditField.Position = [103 54 100 22];

            % Create RMSEEditFieldLabel
            app.RMSEEditFieldLabel = uilabel(app.Panel);
            app.RMSEEditFieldLabel.HorizontalAlignment = 'right';
            app.RMSEEditFieldLabel.Position = [48 33 40 22];
            app.RMSEEditFieldLabel.Text = 'RMSE';

            % Create RMSEEditField
            app.RMSEEditField = uieditfield(app.Panel, 'numeric');
            app.RMSEEditField.Position = [103 33 100 22];

            % Create SSEEditFieldLabel
            app.SSEEditFieldLabel = uilabel(app.Panel);
            app.SSEEditFieldLabel.HorizontalAlignment = 'right';
            app.SSEEditFieldLabel.Position = [59 12 29 22];
            app.SSEEditFieldLabel.Text = 'SSE';

            % Create SSEEditField
            app.SSEEditField = uieditfield(app.Panel, 'numeric');
            app.SSEEditField.Position = [103 12 100 22];

            % Create Image
            app.Image = uiimage(app.UIFigure);
            app.Image.Position = [27 365 100 100];
            app.Image.ImageSource = 'logo.png';

            % Create HowtoUseLabel
            app.HowtoUseLabel = uilabel(app.UIFigure);
            app.HowtoUseLabel.FontSize = 18;
            app.HowtoUseLabel.FontWeight = 'bold';
            app.HowtoUseLabel.FontAngle = 'italic';
            app.HowtoUseLabel.Position = [446 125 103 22];
            app.HowtoUseLabel.Text = 'How to Use';

            % Create PressLoadandopenacvsfileformedbytowcolumsofdataLabel
            app.PressLoadandopenacvsfileformedbytowcolumsofdataLabel = uilabel(app.UIFigure);
            app.PressLoadandopenacvsfileformedbytowcolumsofdataLabel.Position = [321 58 353 54];
            app.PressLoadandopenacvsfileformedbytowcolumsofdataLabel.Text = {'Press "Load" and open a .cvs file, formed by tow colums of data,'; 'then select the type of fitting to use and press "Plot", you will see'; 'in the graph the fitted curve and data point.'; 'To clear the app, press "C".'};

            % Create CurveFittingApplicationLabel
            app.CurveFittingApplicationLabel = uilabel(app.UIFigure);
            app.CurveFittingApplicationLabel.HorizontalAlignment = 'center';
            app.CurveFittingApplicationLabel.FontSize = 21;
            app.CurveFittingApplicationLabel.FontWeight = 'bold';
            app.CurveFittingApplicationLabel.FontAngle = 'italic';
            app.CurveFittingApplicationLabel.Position = [163 391 141 49];
            app.CurveFittingApplicationLabel.Text = {'Curve Fitting '; 'Application'};

            % Create UIAxes
            app.UIAxes = uiaxes(app.UIFigure);
            title(app.UIAxes, 'Fitting Curve')
            xlabel(app.UIAxes, '.')
            ylabel(app.UIAxes, '.')
            zlabel(app.UIAxes, 'Z')
            app.UIAxes.XGrid = 'on';
            app.UIAxes.YGrid = 'on';
            app.UIAxes.Box = 'on';
            app.UIAxes.Position = [333 203 532 272];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = rssid

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end