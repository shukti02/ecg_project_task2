function generatePlots(xdata,ydata,x_st,y_st,xname,yname,tit,type,plot)
%xdata and ydata: rows correspond to features, columns to observations
%x_st and y_st: stem data
%xname, yname, tit and type strings
%type: multiple or single
%plot: box,hist,stem,plot,stemPlot

%if xdata is empty generate histogram and boxplot
if (strcmp(type,'multiple'))
    switch plot
        case 'box',
            for i = 1 : size(ydata,1)
                if (iscell(ydata))                    
                    boxplot(ydata{i});
                else
                    boxplot(ydata(i,:));
                end
                title(strcat(tit,' boxplot\_fea',num2str(i)));
                saveas(gcf,strcat(tit,' boxplot_fea',num2str(i),'.jpg'));
                clf; close all
            end
        case 'hist',
            for i = 1 : size(ydata,1)
                if (iscell(ydata))
                    histfit(ydata{i});
                else
                    histfit(ydata(i,:));
                end
                title(strcat(tit,' histogram\_fea',num2str(i)));
                saveas(gcf,strcat(tit,' histogram_fea',num2str(i),'.jpg')); 
                clf; close all
            end         
        case 'stemPlot',
            if (ischar(ydata))
                y_file = matfile(ydata); %generally reference to filtered leads
                if(~ismember('V2',fieldnames(y_file)))
                    disp('invalid file')
                    return
                end
            end
            if (ischar(xdata))
                x_file = matfile(xdata);
            end

%             div = floor(length(x_st)/60);
%             for j = 1 : div-1       
%                 for i = (j-1)*60+1 : j*60
%                     a = y_file.V2(1,x_st(i)-49:x_st(i)+50);
%                     a = -1.*a;
%                     plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),y_st(i),'r'); hold on;
%                 end
%                 xlabel('time');
%                 ylabel('magnitude');
%                 title(strcat(tit,'interval',num2str(j)));
%                 saveas(gcf,strcat(tit,'interval',num2str(j),'.jpg'));
%                 clf; close all;
%             end
%             for i = (div-1)*60+1 : length(x_st)
%                 a = y_file.V2(1,x_st(i)-49:x_st(i)+50);
%                 a = -1.*a;
%                 plot((length(a)*(i-1))+1:i*length(a),a,'b'); hold on; stem(50+((i-1)*100),y_st(i),'r'); hold on;
%             end
%             xlabel('time');
%             ylabel('magnitude');
%             title(strcat(tit,'interval',num2str(div)));
%             saveas(gcf,strcat(tit,'interval',num2str(div),'.jpg'));
%             clf; close all
            i = 0;      
            div = floor(length(y_file.V2)/10000);
            for j = 1 : div-1
                a1 = x_st(x_st>=(j-1)*10000+1 & x_st<=j*10000);
                if (~isempty(a1))
                    b1 = y_file.V2(1,(j-1)*10000+1:j*10000);
                    b1 = -1.*b1;
                    c1 = b1(a1(1,:)-(j-1)*10000);
                    i = i+1;
                    subplot(2,2,i)
                    plot((j-1)*10000+1:j*10000,b1); hold on; stem(a1,c1); hold on;
                    xlabel('time');
                    ylabel('magnitude');
                    title(strcat(tit,'\_interval',num2str(j)));                    
                end
                if (i==4)
                    saveas(gcf,strcat(tit,'_interval',num2str(j-4),'to',num2str(j),'.jpg'));
                    i = 0;
                    clf; close all;
                end                
            end
            a1 = x_st(x_st>=(div-1)*10000+1);
            if (~isempty(a1))
                b1 = y_file.V2(1,(div-1)*10000+1:end);
                b1 = -1.*b1;
                c1 = b1(a1(1,:)-(div-1)*10000);            
                plot((div-1)*10000+1:div*10000,b1); hold on; stem(a1,c1);
                xlabel('time');
                ylabel('magnitude');
                title(strcat(tit,'\_interval',num2str(div)));
                saveas(gcf,strcat(tit,'_interval',num2str(div),'.jpg'));
            end
            clf; close all;
            
        case 'stem',
            
        case 'plot',
            
        otherwise
            disp('unknown plot');      
    end
elseif (strcmp(type,'single'))
     switch plot
        case 'box',
            1;
        case 'hist',
           2;
        case 'stemPlot',
            
        case 'stem',
            
        case 'plot',
            
        otherwise
            disp('unknown plot');      
     end
else
    disp('unknown type');
end

end