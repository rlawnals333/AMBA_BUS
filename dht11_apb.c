#include <stdint.h>
//땔때 반응 => start_trigger  1번 이라서 오류는 안나옴 state 오류 안나옴 
#define __IO volatile // 최적화없이 있는 그대로 값 사용 
typedef struct{
    __IO uint32_t MODER; // 1: outputmode 0: inputmode 
    __IO uint32_t IDR;  // input data
    __IO uint32_t ODR;  // output data 
} GPIO_TypeDef;

typedef struct{
    __IO uint32_t FCR; // enable/disable
    __IO uint32_t FDR; //fnd data
    __IO uint32_t FPR; // fnd dot point 
} FND_TypeDef;

typedef struct{
    __IO uint32_t FFE; //fifo full_tx/ empty_rx / full_rx/ empty_rx
    __IO uint32_t FWD; //fifo write data // tx_in 
    __IO uint32_t FRT; // tx read data
    __IO uint32_t FRR; //fifo read data 
    __IO uint32_t STR; //start_trigger
} UART_TypeDef;

// typedef struct{
//     __IO uint32_t FFE; //fifo full/ empty
//     __IO uint32_t FWD; //fifo write data // 
//     __IO uint32_t FRD;
//  //fifo read data // only read 
// } UART_RX_TypeDef;

typedef struct{
    __IO uint32_t TCR; //msb 2bit clear/ enable
    __IO uint32_t TCNT; //count
    __IO uint32_t PSC; //tick count limit
    __IO uint32_t ARR; // counter limit
} TIM_TypeDef;

typedef struct{
    __IO uint32_t STR; //start_trigger
    __IO uint32_t DOR; //dataout
    __IO uint32_t DCR; //is_done/checksum
} DHT_TypeDef;

typedef struct{
    __IO uint32_t STR; //start_trigger
    __IO uint32_t DOR; //dataout
    
} SR_TypeDef;


#define APB_BASEADDR 0x10000000 //0
#define GPIOA_BASEADDR (APB_BASEADDR + 0x1000)//1
#define GPIOB_BASEADDR (APB_BASEADDR + 0x3000)//2
#define SR_BASEADDR (APB_BASEADDR + 0x2000)//2
// #define UART_RX_BASEADDR (APB_BASEADDR + 0x3000)//3
// #define GPIOD_BASEADDR (APB_BASEADDR + 0x4000)//4
#define DHT_BASEADDR (APB_BASEADDR + 0x4000) //psel4
#define FND_BASEADDR (APB_BASEADDR + 0x5000) //psel5
#define UART_BASEADDR (APB_BASEADDR + 0x6000) //psel6
#define TIM_BASEADDR (APB_BASEADDR + 0x7000) //psel6


#define GPIOA ((GPIO_TypeDef *) GPIOA_BASEADDR)
#define GPIOB ((GPIO_TypeDef *) GPIOB_BASEADDR)
#define SR ((SR_TypeDef *) SR_BASEADDR)
// #define UART_RX ((UART_RX_TypeDef *) UART_RX_BASEADDR)
// #define GPIOD ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define DHT ((DHT_TypeDef *) DHT_BASEADDR)
#define FND ((FND_TypeDef *) FND_BASEADDR)
#define UART ((UART_TypeDef *) UART_BASEADDR)

#define TIM ((TIM_TypeDef *) TIM_BASEADDR)


void LED_init(GPIO_TypeDef *GPIOx);

void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);

void Switch_init(GPIO_TypeDef *GPIOx);

uint32_t Switch_read(GPIO_TypeDef *GPIOx);




void FND_ENABLE(FND_TypeDef *FNDx);
void FND_DISABLE(FND_TypeDef *FNDx);
void FND_COMM(FND_TypeDef *FNDx, uint32_t data);
void FND_FONT(FND_TypeDef *FNDx, uint32_t data);
void FND_DOT(FND_TypeDef *FNDx, uint32_t data);

uint32_t TX_isFE(UART_TypeDef * UARTx);
uint32_t RX_isFE(UART_TypeDef * UARTx);
void TX_WRITE(UART_TypeDef * UARTx, char data);
uint32_t TX_READ(UART_TypeDef * UARTx);
char RX_READ(UART_TypeDef * UARTx);
void TX_start(UART_TypeDef * UARTx,TIM_TypeDef* TIMx);

void TIM_start(TIM_TypeDef *TIMx);
void TIM_stop(TIM_TypeDef *TIMx);
void TIM_clear(TIM_TypeDef *TIMx);
uint32_t TIM_readCounter(TIM_TypeDef *TIMx);
void TIM_writePsc(TIM_TypeDef *TIMx,uint32_t data);
void TIM_writeArr(TIM_TypeDef *TIMx,uint32_t data);

void delay_time(TIM_TypeDef *TIMx, uint32_t limit_time);

uint32_t power_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy);
uint32_t btn1_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy);
uint32_t btn2_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy);
uint32_t btn3_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy);
uint32_t btn4_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy);

void DHT_start(DHT_TypeDef * DHTx, TIM_TypeDef *TIMx);
void DHT_stop(DHT_TypeDef * DHTx);
uint32_t read_DHT(DHT_TypeDef * DHTx);
uint32_t read_CHK(DHT_TypeDef *DHTx);

void SR_start(SR_TypeDef * SRx, TIM_TypeDef* TIMx);//한번번
uint32_t read_SR(SR_TypeDef * SRx);
uint32_t SR04_run(SR_TypeDef * SRx,TIM_TypeDef *TIMx);


void TIM_init_1us(TIM_TypeDef *TIMx, uint32_t psc, uint32_t arr);


uint32_t DHT11_run(DHT_TypeDef * DHTx,TIM_TypeDef *TIMx);
//0.1초 10**7

void UART_send(UART_TypeDef * UARTx,TIM_TypeDef *TIMx,char data);
uint32_t DHT11_operation(DHT_TypeDef*DHTx,UART_TypeDef * UARTx,TIM_TypeDef* TIMx);
uint32_t SR04_operation(SR_TypeDef* SRx,UART_TypeDef * UARTx,TIM_TypeDef* TIMx);
void FND_control(FND_TypeDef *FNDx,GPIO_TypeDef* GPIOx, uint32_t en);

int main()
{

    uint32_t time_B_toggle;
    Switch_init(GPIOA);
    LED_init(GPIOB);
    
    TIM_init_1us(TIM,100,10000000); // 1us/ 10초 카운트
    TIM_clear(TIM);
    TIM_start(TIM);
    uint32_t dht11_data;
    uint32_t RH_int, RH_dec, T_int, T_dec; 
    uint32_t temp_RH_int;
    uint32_t temp_T_int;
    uint32_t sr04_data;
    uint32_t save_state;
    


    // Switch_init(GPIOB);

    // timer 버튼 뗄뗴 동작작
    time_B_toggle = 1;
   
   // 컴파일러때매 어쩔수 없ㄷ음음
    // uint32_t *ascii_num[2] = {&tens,&ones};
     // 온습도 보낼때 8비트씩 보내려고 저장  //공간을 만들때는 ram 활용
    // ram / rom / 나누기 4를 하고 주소값을 들어가기 때문에 무조건 4byte 단위로 공간 생성 즉 메모리공간생성 시에는 32비트로 
    //걍 불러올때는 word / byte / half 형식에 따라 상관없음  


     while(1)
    {   
        
        FND_control(FND,GPIOA,(1<<0));
        


     //  온습도
       
     
            //  while(1){
            // delay_time(TIM,3000000);
             dht11_data = DHT11_operation(DHT,UART,TIM);
             sr04_data = SR04_operation(SR,UART,TIM);
             RH_int = (dht11_data >> 24) & 0xFF;
             T_int = (dht11_data >> 8) & 0xFF;
             RH_dec = (dht11_data >> 16 ) & 0xFF ;
             T_dec = dht11_data & 0xFF;
            //  temp_RH_int = RH_int;
            //  temp_T_int = T_int ;

            
            //  for(int i=0; i<100; i++) { RH_int += temp_RH_int; T_int += temp_T_int;}
        

             LED_write(GPIOB,(1 << 5)+GPIOB -> ODR);
             delay_time(TIM,2000000); // 신호 대기 
             save_state = RX_READ(UART);
             if((char)save_state == 'D') { 
                if(sr04_data >= 400) {LED_write(GPIOB,1); FND_FONT(FND,20000);FND_DOT(FND,0);} // 400이상상
                else if(sr04_data < 10) {FND_FONT(FND,sr04_data);FND_DOT(FND,0);LED_write(GPIOB,(1 << 4) + 1);} // 10이하 경보보
                else {FND_FONT(FND,sr04_data);FND_DOT(FND,0);LED_write(GPIOB,1);}} // 평소

            else if((char)save_state == 'H') { 
                if(temp_RH_int > 40) {LED_write(GPIOB,(1 << 4)+(1<<1)); FND_FONT(FND,RH_int); FND_DOT(FND,(1<<2));} //40 이상
                else {LED_write(GPIOB,(1<<1)); FND_FONT(FND,RH_int); FND_DOT(FND,(1<<2));}
                                            }

             else if((char)save_state == 'T') { 
                if(temp_T_int > 30) {LED_write(GPIOB,(1<<2) + (1 <<4)); FND_FONT(FND,T_int);FND_DOT(FND,(1<<2));} // 30도 이상상
                else {LED_write(GPIOB,(1<<2)); FND_FONT(FND,T_int);FND_DOT(FND,(1<<2));}
             }
             
             else if((char)save_state == 'S') {{FND_FONT(FND,0);FND_DOT(FND,0xf);LED_write(GPIOB,0); while(RX_READ(UART) != 'R'){} }}
             else { {FND_FONT(FND,10000);FND_DOT(FND,0);LED_write(GPIOB,7); }}
            
             TIM_clear(TIM);
             TIM_start(TIM);
               
            
            LED_write(GPIOB,(1 << 5)+GPIOB -> ODR);

        // if((Switch_read(GPIOA) & (1<<1) ) == (1<<1)) {delay_time(TIM,100);  time_B_toggle = TIM_readCounter(TIM); }  // 버튼 누를때 시간 카운트 / toggle값이 0이 안되게 딜레이 
        //     //이타이밍에 떼야됨 
        //     if((Switch_read(GPIOA) & (1<<1) == 0 ) && (TIM_readCounter(TIM) > time_B_toggle) ) {  //10초안에 눌러야함    // 버튼 누른시간보다 뒤에 꺼지면 실행행
        //         if((GPIOB -> ODR)&(1 <<4) == (1 << 4)) {LED_write(GPIOB, (GPIOB -> ODR)&~(1<<4));}
        //         TIM_clear(TIM); // 안눌렀을때 실행 안되게 초기화 
            
        // }
  
           
       

            
            //  else if(RX_READ(UART) == 'S') break;
            // delay_time(TIM,500000);
            // LED_write(GPIOB,0);
            // delay_time(TIM,500000);
             
            
             //계속 read_en 신호 나감 1번만 나가게 버튼 사용  // 배열로 미리 넘길 수 저장 
    }  
return 0;
}




//10000000 -> 0.1초 틱 

void delay_time(TIM_TypeDef *TIMx, uint32_t limit_time)
{   
            TIM_clear(TIMx);
            TIM_start(TIMx); 
    while(TIM_readCounter(TIMx) < limit_time){
                  
    } 
}




void LED_init(GPIO_TypeDef *GPIOx)
{
    GPIOx->MODER = 0xff; //1이면 output 0이면 in 
}

void LED_write(GPIO_TypeDef *GPIOx, uint32_t data)
{
    GPIOx->ODR = data;
}

void Switch_init(GPIO_TypeDef *GPIOx)
{
    GPIOx->MODER = 0x00;
}
uint32_t Switch_read(GPIO_TypeDef *GPIOx)
{
    return GPIOx->IDR;
}

void FND_ENABLE(FND_TypeDef *FNDx)
{
    FNDx->FCR = 1;
}

void FND_DISABLE(FND_TypeDef *FNDx)
{
    FNDx->FCR = 0;
}

void FND_FONT(FND_TypeDef *FNDx, uint32_t data)
{
    FNDx->FDR = data;
}

void FND_DOT(FND_TypeDef *FNDx, uint32_t data) {
    FNDx ->FPR = data;
}

void FND_control(FND_TypeDef *FNDx,GPIO_TypeDef* GPIOx, uint32_t en) {
    if((Switch_read(GPIOx) & en) == en) {
        FND_ENABLE(FNDx);
}        else {
        FND_DISABLE(FNDx);
}  

}
uint32_t TX_isFE(UART_TypeDef * UARTx) {
    return (UARTx -> FFE) & (0x03 << 2);
}
uint32_t RX_isFE(UART_TypeDef * UARTx) {
    return (UARTx -> FFE) & 0x03;
}
void TX_WRITE(UART_TypeDef * UARTx,  char data) {
    UARTx -> FWD = (uint32_t)data;
}

uint32_t TX_READ(UART_TypeDef * UARTx) {
    return UARTx -> FRT;
}

char RX_READ(UART_TypeDef * UARTx) {
    if(RX_isFE(UARTx) != 1) {
    return (char)((UARTx -> FRR) & 0xFF);} // empty  아닐때만 read함 
    else {
    return  0;
    }
}

void TX_start(UART_TypeDef * UARTx,TIM_TypeDef *TIMx) {
    UARTx -> STR = (1<<0);
    delay_time(TIMx,10);
    UARTx -> STR = 0;
}

void UART_send(UART_TypeDef * UARTx,TIM_TypeDef *TIMx,char data){
    uint32_t tx_data;
    if(TX_isFE(UARTx)!=(1 << 1) ){
        TX_WRITE(UARTx, data);
        tx_data = TX_READ(UARTx);
        TX_start(UARTx,TIMx);
         //FND_DOT(FND,0x1111); // RH T  나오게? 
        delay_time(TIMx,30000);
         }
}

void TIM_start(TIM_TypeDef *TIMx){
    TIMx ->TCR =  (1<<0);
    // TIMx ->TCR &=  ~(1<<1);
}
void TIM_stop(TIM_TypeDef *TIMx){
     TIMx ->TCR =  (0<<0);
    // TIMx ->TCR &=  ~(1<<1);
}
void TIM_clear(TIM_TypeDef *TIMx){
    TIMx ->TCR = (1<<1);
}
uint32_t TIM_readCounter(TIM_TypeDef *TIMx){
    return TIMx -> TCNT;
}
void TIM_writePsc(TIM_TypeDef *TIMx,uint32_t data){
    TIMx -> PSC = data;
}
void TIM_writeArr(TIM_TypeDef *TIMx,uint32_t data){
    TIMx -> ARR = data;
}


//DHT11
void DHT_start(DHT_TypeDef * DHTx, TIM_TypeDef* TIMx){ //한번번
    DHTx -> STR = (1 << 0);
    delay_time(TIMx,10);
    DHTx -> STR = (0 << 0);
}

void DHT_stop(DHT_TypeDef * DHTx){
    DHTx -> STR = (0 << 0);
}
uint32_t read_DHT(DHT_TypeDef * DHTx){
    return DHTx -> DOR;
}
uint32_t read_CHK(DHT_TypeDef *DHTx){
     return DHTx -> DCR;
}

void TIM_init_1us(TIM_TypeDef *TIMx, uint32_t psc, uint32_t arr){
      TIM_writePsc(TIMx,psc); //1us 틱 
      TIM_writeArr(TIMx,arr); //10초까지 샘
} // 1us 정하기 

uint32_t DHT11_run(DHT_TypeDef * DHTx,TIM_TypeDef *TIMx){
    // if(read_DONE(DHTx) == 1) {
        DHT_start(DHTx,TIMx);
        delay_time(TIMx,300000); //300ms 대기 // dht11 측정끝날때 까지 대기 
        // if(read_CHK(DHTx) == 1) {
            return read_DHT(DHTx);
        // }
        // else return 1;
  }
// }
void SR_start(SR_TypeDef * SRx, TIM_TypeDef* TIMx){ //한번번
    SRx -> STR = (1 << 0);
    delay_time(TIMx,10);
    SRx -> STR = (0 << 0);
}

uint32_t read_SR(SR_TypeDef * SRx){
    return SRx -> DOR;
}

uint32_t SR04_run(SR_TypeDef * SRx,TIM_TypeDef *TIMx){
    // if(read_DONE(DHTx) == 1) {
        SR_start(SRx,TIMx);
        delay_time(TIMx,300000); //300ms 대기 // dht11 측정끝날때 까지 대기 
        // if(read_CHK(DHTx) == 1) {
        return read_SR(SRx);
        // }
        // else return 1;
  }


uint32_t DHT11_operation(DHT_TypeDef*DHTx,UART_TypeDef * UARTx,TIM_TypeDef* TIMx){
    uint32_t ze;
    uint32_t ei;
    uint32_t si;
    uint32_t tw;
    uint32_t dht_odata;
    uint32_t temp_dht;
    uint32_t dht_tens; // 주소값 4 바이트 
    uint32_t dht_ones;
    uint32_t *shift_num[4] = {&tw,&si,&ei,&ze}; 

    ze = 0;
    ei = 8;
    si = 16;
    tw = 24;

    dht_odata = DHT11_run(DHTx,TIMx);
            for (int i =0; i<4; i++) {
                temp_dht = (dht_odata >> *(shift_num[i])) & 0xFF; //shift가 왜 2번만? 
                dht_tens = 0;
                dht_ones = 0; // 매번 초기화 
                while(temp_dht >= 10) { //10의자리 1의자리 뽑아내기 */%못써서 이거씀 
                        temp_dht -= 10;
                        dht_tens ++;
                }
                    dht_ones = temp_dht;
                switch (i)
                {
                case 0:
                    UART_send(UARTx,TIMx,'R');
                    UART_send(UARTx,TIMx,'H');
                    UART_send(UARTx,TIMx,':');
                    UART_send(UARTx,TIMx,(char)(dht_tens+'0'));
                    UART_send(UARTx,TIMx,(char)(dht_ones+'0'));
                    UART_send(UARTx,TIMx,'.');
                    break;
                case 1:
                    UART_send(UARTx,TIMx,(char)dht_tens + '0');
                    UART_send(UARTx,TIMx,(char)dht_ones + '0');
                    UART_send(UARTx,TIMx,'%');
                    UART_send(UARTx,TIMx,' ');
                    break;
                
                case 2:
                    UART_send(UARTx,TIMx,'T');
                    UART_send(UARTx,TIMx,':');
                    UART_send(UARTx,TIMx,(char)(dht_tens+'0'));
                    UART_send(UARTx,TIMx,(char)(dht_ones+'0'));
                    UART_send(UARTx,TIMx,'.');
                    break;
                
                case 3:
                    UART_send(UARTx,TIMx,(char)dht_tens + '0');
                    UART_send(UARTx,TIMx,(char)dht_ones + '0');
                    UART_send(UARTx,TIMx,'C');
                    UART_send(UARTx,TIMx,'\n');
                    break;

                }
               
            }  
            return dht_odata;
           
}

uint32_t SR04_operation(SR_TypeDef* SRx,UART_TypeDef * UARTx,TIM_TypeDef* TIMx){

    uint32_t sr_odata;
    uint32_t SR_huns;
    uint32_t SR_tens;
    uint32_t SR_ones;
    uint32_t temp_result;

    sr_odata = SR04_run(SRx,TIMx);
    SR_huns = 0;
    SR_tens = 0;
    SR_ones = 0; // 매번 초기화 
    temp_result = sr_odata;
    
    while(sr_odata >= 100) { //10의자리 1의자리 뽑아내기 */%못써서 이거씀 
        sr_odata -= 100;
        SR_huns ++;
            }
    
    while(sr_odata >= 10) { //10의자리 1의자리 뽑아내기 */%못써서 이거씀 
        sr_odata -= 10;
        SR_tens ++;
             }
        SR_ones = sr_odata;
    UART_send(UARTx,TIMx,'D');
    UART_send(UARTx,TIMx,'I');
    UART_send(UARTx,TIMx,'S');
    UART_send(UARTx,TIMx,'T');
    UART_send(UARTx,TIMx,'A');
    UART_send(UARTx,TIMx,'N');
    UART_send(UARTx,TIMx,'C');
    UART_send(UARTx,TIMx,'E');
    UART_send(UARTx,TIMx,':');
    UART_send(UARTx,TIMx,(char)(SR_huns+'0'));
    UART_send(UARTx,TIMx,(char)(SR_tens+'0'));
    UART_send(UARTx,TIMx,(char)(SR_ones+'0'));
    UART_send(UARTx,TIMx,'c');
    UART_send(UARTx,TIMx,'m');
    UART_send(UARTx,TIMx,'\n');

    return temp_result;
                           
        }

    