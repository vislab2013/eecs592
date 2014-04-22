global tname;
name = 'PARSE';
ioption = 1;

toption = 7;
tname = 't07i01';
globals;

savename = [cachedir name '_boxes_66666666666666666666666666_new'];
load(savename);
[~,~,test] = PARSE_data(name,toption,ioption);
apk50 = PARSE_eval_apk(boxes,test);
meanapk50 = mean(apk50);

savename = [cachedir name '_boxes_gtbox_66666666666666666666666666_new'];
load(savename);
pck50 = PARSE_eval_pck(boxes,test);
meanpck50 = mean(pck50);

toption = 8;
tname = 't08i01';
globals;

savename = [cachedir name '_boxes_66666666666666666666666666_new'];
load(savename);
[~,~,test] = PARSE_data(name,toption,ioption);
apk80 = PARSE_eval_apk(boxes,test);
meanapk80 = mean(apk80);

savename = [cachedir name '_boxes_gtbox_66666666666666666666666666_new'];
load(savename);
pck80 = PARSE_eval_pck(boxes,test);
meanpck80 = mean(pck80);

toption = 2;
tname = 't02i01';
globals;

savename = [cachedir name '_boxes_66666666666666666666666666_new'];
load(savename);
[~,~,test] = PARSE_data(name,toption,ioption);
apk100 = PARSE_eval_apk(boxes,test);
meanapk100 = mean(apk100);

savename = [cachedir name '_boxes_gtbox_66666666666666666666666666_new'];
load(savename);
pck100 = PARSE_eval_pck(boxes,test);
meanpck100 = mean(pck100);

X = [50 80 100];
APK = [meanapk50 meanapk80 meanapk100]*100;
PCK = [meanpck50 meanpck80 meanpck100]*100;

figure;
plot(X,PCK,'b','LineWidth',2); hold on;
plot(X,APK,'r','LineWidth',2);
axis([50 100 33 60])
set(gca,'XTick',X)
set(gca,'XTickLabel',{'50' '80' '100'})
xlabel('Number of Training Images','FontSize',14);
ylabel('Accuracy (%)','FontSize',14);
legend('PCK   ','APK   ','Location','SouthEast');
set(gca,'FontSize',12);
print(gcf,'-dpdf','train_num.pdf');


