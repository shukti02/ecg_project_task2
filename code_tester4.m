i = 0;
tit = 'misdetections';
for j = 34768 : 34776
    a1 = x_st(x_st>=(j-1)*10000+1 & x_st<=j*10000);
    if (~isempty(a1))
        b1 = y_file.V2(1,(j-1)*10000+1:j*10000);
        b1 = -1.*b1;
        c1 = b1(a1(1,:)-(j-1)*10000);
        i = i + 1;
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