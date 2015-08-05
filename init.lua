start_init = function() 
wifi.setmode(wifi.STATIONAP);
wifi.ap.config({ssid="traffic",pwd="12345678"});
print("AP address: " .. wifi.ap.getip())
gpio.mode(7, gpio.OUTPUT); 
gpio.mode(5, gpio.OUTPUT); 
gpio.mode(0, gpio.OUTPUT);
gpio.write(7,gpio.LOW); 
gpio.write(5,gpio.LOW); 
gpio.write(0,gpio.LOW); 
gpio2_state=0; 
gpio0_state=0; 
gpio1_state=0; 
value = 0;
amber = 0;
red = 0;
counter = 0;
end 
 
sendFileContents = function(conn, filename) 
    if file.open(filename, "r") then 
        --conn:send(responseHeader("200 OK","text/html")); 
        repeat  
        local line=file.readline()  
        if line then  
            conn:send(line); 
        end  
        until not line  
        file.close(); 
    else 
        conn:send(responseHeader("404 Not Found","text/html")); 
        conn:send("Page not found"); 
            end 
end 
 
responseHeader = function(code, type) 
    return "HTTP/1.1 " .. code .. "\r\nConnection: close\r\nServer: nunu-Luaweb\r\nContent-Type: " .. type .. "\r\n\r\n";  
end 
 
httpserver = function () 
    start_init(); 
 srv=net.createServer(net.TCP)  
    srv:listen(80,function(conn)  
      conn:on("receive",function(conn,request)  
        conn:send(responseHeader("200 OK","text/html")); 
        if string.find(request,"gpio=0") then 
            if gpio0_state==0 then 
                gpio0_state=1; 
                gpio.write(7,gpio.HIGH); 
            else 
                gpio0_state=0; 
                gpio.write(7,gpio.LOW); 
            end 
        elseif string.find(request,"gpio=2") then 
            if gpio2_state==0 then 
                gpio2_state=1; 
                gpio.write(5,gpio.HIGH); 
            else 
                gpio2_state=0; 
                gpio.write(5,gpio.LOW); 
            end 
        elseif string.find(request,"gpio=1") then 
            if gpio1_state==0 then 
                gpio1_state=1; 
                gpio.write(0,gpio.HIGH); 
            else 
                gpio1_state=0; 
                gpio.write(0,gpio.LOW); 
            end 
        elseif string.match(request,"val") then 
             local t={};i=1
             for str in string.gmatch(request, "([^%s]+)") do
                      t[i] = str
                i = i + 1;
               end
             value = tonumber(t[1])
             if value <= 60 then
               amber = value + 30
               red = value + 60
             else
               amber = value + 60
               red = value + 120
             end
                     gpio.write(0,gpio.HIGH); 
                     gpio1_state=1;
             tmr.alarm(0, value *1000, 0, function() 
             
               --counter = counter + 1;
               --print("hello world" ..counter) 
               --if gpio1_state==0 then 
               --      gpio1_state=1; 
               --      gpio.write(0,gpio.HIGH); 
               --  else 
               --      gpio1_state=0; 
                     gpio.write(0,gpio.LOW); 
                     
                     gpio1_state=0;
                     gpio.write(5,gpio.HIGH);
                     
                     gpio2_state=1;
              --   end 
                 
               --if counter>10 then
                --    tmr.stop(0)
                --    counter = 0
               --end
              end )
              tmr.alarm(1, amber *1000, 0, function()
              gpio.write(5,gpio.LOW);
              gpio2_state=0;
              gpio.write(7,gpio.HIGH);
               gpio0_state=1;
              end)
              tmr.alarm(2, red *1000, 0, function()
              gpio.write(7,gpio.LOW);
              gpio0_state=0;
              end)
        else 
            if gpio0_state==0 then 
                preset0_on=""; 
            end 
            if gpio0_state==1 then 
                preset0_on="checked=\"checked\""; 
            end 
            if gpio1_state==0 then 
                preset1_on=""; 
            end 
            if gpio1_state==1 then 
                preset1_on="checked=\"checked\""; 
            end 
            if gpio2_state==0 then 
                preset2_on=""; 
            end 
            if gpio2_state==1 then 
                preset2_on="checked=\"checked\""; 
            end 
            
            sendFileContents(conn,"header.htm"); 
            conn:send("<div><input type=\"checkbox\" id=\"checkbox0\" name=\"checkbox0\" class=\"switch\" onclick=\"loadXMLDoc(0)\" "..preset0_on.." />"); 
            conn:send("<label for=\"checkbox0\">Red</label></div>"); 
            conn:send("<div><input type=\"checkbox\" id=\"checkbox2\" name=\"checkbox2\" class=\"switch\" onclick=\"loadXMLDoc(2)\" "..preset2_on.." />"); 
            conn:send("<label for=\"checkbox2\">Amber</label></div>"); 
            conn:send("<div><input type=\"checkbox\" id=\"checkbox1\" name=\"checkbox1\" class=\"switch\" onclick=\"loadXMLDoc(1)\" "..preset1_on.." />"); 
            conn:send("<label for=\"checkbox1\">Green</label></div>"); 
            
            conn:send("<div><form action=\"\" method=\"post\" name=\"formxml\"><input type=\"text\" name=\"xmlname\" id=\"xmlname\"><input type=\"button\" onclick=\"foo();\" value=\"Submit\"></form>"); 
            conn:send("<label for=\"xmlname\">Enter the green time in seconds</label></div>");             
            conn:send("</div>"); 
        end 
        print(request); 
      end)  
      conn:on("sent",function(conn)  
        conn:close();  
        conn = nil;     
 
      end) 
    end) 
end 
 
httpserver()
-- GPIO pin   IO index
-- GPIO0     3
-- GPIO1     10
-- GPIO2     4
-- GPIO3     9
-- GPIO4     2
-- GPIO5     1
-- GPIO6     N/A
-- GPIO7     N/A
-- GPIO8     N/A
-- GPIO9     11
-- GPIO10    12
-- GPIO11    N/A
-- GPIO12    6
-- GPIO13    7
-- GPIO14    5
-- GPIO15    8
-- GPIO16    0