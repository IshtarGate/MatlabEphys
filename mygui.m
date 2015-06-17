function mygui(data)
    % Create a figure and axes
    f=figure(1);
%     ax = axes('Units','pixels');
    plot(data)
    
    % Create pop-up menu
%     popup = uicontrol('Style', 'popup',...
%            'String', {'parula','jet','hsv','hot','cool','gray'},...
%            'Position', [20 340 100 50],...
%            'Callback', @setmap);    
    
   % Create push button
    btn = uicontrol('Style', 'pushbutton', 'String', 'Clear',...
        'Position', [20 20 50 20],...
        'Callback', 'cla');       

   % Create slider
    sld = uicontrol('Style', 'slider',...
        'Min',1,'Max',50,'Value',41,...
        'Position', [400 20 120 20],...
        'Callback', @slidercontrol); 
					
    % Add a text uicontrol to label the slider.
    txt = uicontrol('Style','text',...
        'Position',[400 45 120 20],...
        'String','Vertical Exaggeration');
    
    % Make figure visble after adding all components
    set(f,'Visible','on')
    
    function setmap(source,callbackdata)
        val = source.Value;
        maps = source.String;
        newmap = maps{val};
        colormap(newmap);
    end

    function slidercontrol(source,callbackdata)
       val = source.Value;
       axis([0,1000,-val,val]);
    end
end