
clc;
clear all;
close all;
function []= FINALCODE( )

 str={'RELIANCE.NS','INFY.NS','HEROMOTOC.NS','SBIN.NS','ICICIBANK.NS','HCLTECH.NS',...
     'LT.NS','ULTRACEMC.NS','GRASIM.NS','GLAXO.NS','OFSS.NS','EICHERMOT.NS','ABAN.NS','RIL.BO','NESTLE.BO',...
     'TECHM.BO','BOSCHQF.BO','SIEME.BO','LNTQF.BO','GLENMARK.BO'};
[s,v] = listdlg('PromptString','Select a Company:',...
                'SelectionMode','single',...
                'ListString',str);
 x=str(s);        
 
prompt = {'Enter the date to be predicted (mm/dd/yyyy): '};
dlg_title = 'Date';
num_lines = 1;
def = {'1/1/2014'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
display('Date of Prediction : ');
display(answer);

setdemorandstream(491218382);
string=input('Enter the date to be predicted mm/dd/yyyy: ','s');
y = yahoo;
StockData= fetch(y, x, {'Adj Close' 'Close'  'High'  'Low'  'Open'  'Volume' },string, '1/1/2003', 'd');
StockData = flipud(StockData);
stock = StockData((1:(end-1)),:);
date = datestr(stock(:,1));
AdjClose = stock(:,2);
Close = stock(:,3);
High = stock(:,4);
Low = stock(:,5);
Open = stock(:,6);
Volume = stock(:,7);
[Short,Long]= movavg(AdjClose,5,25,'e');   
chosc = chaikosc(High, Low,Close, Volume)/1e5 ;  
[pctk, pctd] = fpctkd(High, Low, Close);  
[spctk, spctd] = spctkd(pctk, pctd);  
hhv = hhigh(High);  
llv = llow(Low);     
wpctr = willpctr(High, Low, Close);  
rsi = rsindex(Close);  
[macdvec, nineperma] = macd(Close); 
[midfts, upprfts, lowrfts] = bollinger(Close);                                   

Para = Close ;
Oscillators = [ spctk spctd pctk pctd wpctr Long rsi Short macdvec Close Open High Low midfts upprfts lowrfts ];


Delay = 4;

inputSeries = tonndata(Oscillators,false,false);
targetSeries = tonndata(Para,false,false);

inputDelays = 1:Delay;
feedbackDelays = 1:Delay;
hiddenLayerSize = 104;
net = narxnet(inputDelays,feedbackDelays,hiddenLayerSize);

[inputs,inputStates,layerStates,targets] = preparets(net,inputSeries,{},targetSeries);

net.divideParam.trainRatio = 70/100;
net.divideParam.valRatio = 15/100;
net.divideParam.testRatio = 15/100;


net.trainParam.min_grad = 1e-15;
net.trainParam.mu_max= 1e20;
net.trainParam.max_fail = 6;

[net,tr] = train(net,inputs,targets,inputStates,layerStates);

nets = removedelay(net);
nets.name = [net.name ' - Predict One Step Ahead'];

[xs,xis,ais,ts] = preparets(nets,inputSeries,{},targetSeries);
ys = nets(xs,xis,ais);
earlyPredictPerformance = perform(nets,ts,ys);
inputSeries = tonndata(Oscillators,false,false);
targetSeries = tonndata(Para,false,false);
[inputs,inputStates,layerStates,targets] = preparets(nets,inputSeries,{},targetSeries);
Output = sim(nets,inputs, inputStates);
Output = cell2mat(Output)';

Output_stock = Output(end,:)
Target_stock = StockData(end,3 )
error = abs(Target_stock - Output_stock)

PREDICTED = vertcat(Para , Output_stock);
ACTUAL_VALUE = vertcat(Para , Target_stock);
date_axis = date(end-29:end,:);


% Ensemble network

StockData2= fetch(y, x, {'Adj Close' 'Close'  'High'  'Low'  'Open'  'Volume' },'1/1/2012', '1/1/2003', 'd');
StockData2 = flipud(StockData2);
stock2 = StockData2((1:end),:);
date2 = datestr(stock2(:,1));
AdjClose2 = stock2(:,2);
Close2 = stock2(:,3);
High2 = stock2(:,4);
Low2 = stock2(:,5);
Open2 = stock2(:,6);
Volume2 = stock2(:,7);

[Short2,Long2]= movavg(AdjClose2,5,25,'e');    
chosc2 = chaikosc(High2, Low2,Close2, Volume2)/1e5 ; 
[pctk2, pctd2] = fpctkd(High2, Low2, Close2);   
[spctk2, spctd2] = spctkd(pctk2, pctd2);  
hhv2 = hhigh(High2);  
llv2 = llow(Low2);     
wpctr2 = willpctr(High2, Low2, Close2);  
rsi2 = rsindex(Close2);  
[macdvec2, nineperma2] = macd(Close2);
[midfts2, upprfts2, lowrfts2] = bollinger(Close2);                                     

Para2 = Close2 ;
Oscillators2 = [ spctk2 spctd2 pctk2 pctd2 wpctr2 Long2 rsi2 Short2 macdvec2 Close2 Open2 High2 Low2 midfts2 upprfts2 lowrfts2];

StockData1= fetch(y, x, {'Adj Close' 'Close'  'High'  'Low'  'Open'  'Volume' },string, '1/2/2012', 'd');
StockData1 = flipud(StockData1);
stock1 = StockData1(1:end,:);
date1 = datestr(stock1(:,1));
AdjClose1 = stock1(:,2);
Close1 = stock1(:,3);
High1 = stock1(:,4);
Low1 = stock1(:,5);
Open1 = stock1(:,6);
Volume1 = stock1(:,7);

[Short1,Long1]= movavg(AdjClose1,5,25,'e');   
chosc1 = chaikosc(High1, Low1,Close1, Volume1)/1e5 ; 
[pctk1, pctd1] = fpctkd(High1, Low1, Close1);  
[spctk1, spctd1] = spctkd(pctk1, pctd1); 
hhv1 = hhigh(High1); 
llv1 = llow(Low1);     
wpctr1 = willpctr(High1, Low1, Close1);  
rsi1 = rsindex(Close1); 
[macdvec1, nineperma1] = macd(Close1); 
[midfts1, upprfts1, lowrfts1] = bollinger(Close1);                                     

Para1 = Close1 ;
Oscillators1 = [ spctk1 spctd1 pctk1 pctd1 wpctr1 Long1 rsi1 Short1 macdvec1 Close1 Open1 High1 Low1 midfts1 upprfts1 lowrfts1];

ens = fitensemble(Oscillators2,Close2,'Bag',20,'Tree','type','regression');
price1 = ens.predict([Oscillators1(end,:)]);

ens = fitensemble(Oscillators2,Close2,'Bag',50,'Tree','type','regression');
price2 = ens.predict([Oscillators1(end,:)]);

ens = fitensemble(Oscillators2,Close2,'Bag',75,'Tree','type','regression');
price3 = ens.predict([Oscillators1(end,:)]);

ens = fitensemble(Oscillators2,Close2,'Bag',100,'Tree','type','regression');
price4 = ens.predict([Oscillators1(end,:)]);

ens = fitensemble(Oscillators2,Close2,'Bag',125,'Tree','type','regression');
price5 = ens.predict([Oscillators1(end,:)]);

ens = fitensemble(Oscillators2,Close2,'Bag',150,'Tree','type','regression');
price6 = ens.predict([Oscillators1(end,:)]);
ens = fitensemble(Oscillators2,Close2,'Bag',500,'Tree','type','regression');
price7 = ens.predict([Oscillators1(end,:)]);

ens = fitensemble(Oscillators2,Close2,'Bag',10,'Tree','type','regression');
price8 = ens.predict([Oscillators1(end,:)]);

sto=[ abs(Target_stock - price1), abs(Target_stock - price2),abs(Target_stock - price3),abs(Target_stock - price4),abs(Target_stock - price5),abs(Target_stock - price6),abs(Target_stock - price7),abs(Target_stock - price8)];
[Ensemble_error,I] = min(sto);
Ensemble_error


final_price=[price1,price2,price3,price4,price5,price6,price7,price8];
Ensemble_final=final_price(I);
Ensemble_final
Ensemble_final1=ACTUAL_VALUE(end-30:end-1,1);
Ensemble_final1(end+1)=Ensemble_final;

%Plot
Predicted_Price_For_Next_Day = figure;

axes1 = axes('Parent',Predicted_Price_For_Next_Day);
hold(axes1,'all');

hold all;
plot(Para(end-29:end,1),'Parent',axes1,'Marker','.','LineWidth',1,...
    'Color',[0 0.498039215803146 0],...
    'DisplayName','StockPrice');
plot(PREDICTED(end-30:end,1),'Color',[0 0 1],'DisplayName','PREDICTED');
plot(Ensemble_final1(end-30:end,1),'Color',[0 1 0],'DisplayName','ENSEMBLE OUTPUT');
plot(ACTUAL_VALUE(end-30:end,1),'Color',[1 0 0],'DisplayName','ACTUAL VALUE');

legend(axes1,'show');
