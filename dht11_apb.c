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
    __IO uint32_t FFE; //fifo full/ empty
    __IO uint32_t FWD; //fifo write data // tx_in 
    __IO uint32_t FRD; //fifo read data 
    __IO uint32_t STR; //start_trigger
} UART_TX_TypeDef;

typedef struct{
    __IO uint32_t FFE; //fifo full/ empty
    __IO uint32_t FWD; //fifo write data // 
    __IO uint32_t FRD;
 //fifo read data // only read 
} UART_RX_TypeDef;

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


#define APB_BASEADDR 0x10000000 //0
#define GPIOA_BASEADDR (APB_BASEADDR + 0x1000)//1
#define GPIOB_BASEADDR (APB_BASEADDR + 0x2000)//2
#define UART_RX_BASEADDR (APB_BASEADDR + 0x3000)//3
// #define GPIOD_BASEADDR (APB_BASEADDR + 0x4000)//4
#define DHT_BASEADDR (APB_BASEADDR + 0x4000) //psel4
#define FND_BASEADDR (APB_BASEADDR + 0x5000) //psel5
#define UART_TX_BASEADDR (APB_BASEADDR + 0x6000) //psel6
#define TIM_BASEADDR (APB_BASEADDR + 0x7000) //psel6


#define GPIOA ((GPIO_TypeDef *) GPIOA_BASEADDR)
#define GPIOB ((GPIO_TypeDef *) GPIOB_BASEADDR)
#define UART_RX ((UART_RX_TypeDef *) UART_RX_BASEADDR)
// #define GPIOD ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define DHT ((DHT_TypeDef *) DHT_BASEADDR)
#define FND ((FND_TypeDef *) FND_BASEADDR)
#define UART_TX ((UART_TX_TypeDef *) UART_TX_BASEADDR)

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

uint32_t TX_isFE(UART_TX_TypeDef * TX);
uint32_t RX_isFE(UART_RX_TypeDef * RX);
void TX_WRITE(UART_TX_TypeDef *TX, char data);
uint32_t TX_READ(UART_TX_TypeDef *TX);
char RX_READ(UART_RX_TypeDef *RX);
void TX_start(UART_TX_TypeDef* TX,TIM_TypeDef* TIMx);

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


void TIM_init_1us(TIM_TypeDef * TIMx);
void delay(int n);

uint32_t DHT11_run(DHT_TypeDef * DHTx,TIM_TypeDef *TIMx);
//0.1초 10**7

int main()
{


    Switch_init(GPIOA);
    Switch_init(GPIOB);

      uint32_t dht_odata;
      uint32_t dht_Int;
      uint32_t dht_Dec;
      uint32_t time_B_toggle;
      uint8_t temp_dht;

      uint32_t temp_dht_T_Int;
      uint32_t temp_dht_RH_Int;

      uint32_t tx_data;
      uint8_t tens;
      uint8_t ones;

      uint8_t ze;
      uint8_t ei;
      uint8_t si;
      uint8_t tw;

    TIM_init_1us(TIM);
    TIM_clear(TIM);
    time_B_toggle = 1;
   
    uint8_t *shift_num[4] = {&ze,&ei,&si,&tw}; // 컴파일러때매 어쩔수 없ㄷ음음
    uint8_t *ascii_num[2] = {&tens,&ones}; // 온습도 보낼때 8비트씩 보내려고 저장 
    ze = 0;
    ei = 8;
    si = 16;
    tw = 24;

     while(1)
    {      
        
        if((Switch_read(GPIOA) & (1<<0)) == (1 << 0)) {
                FND_ENABLE(FND);
        }        else {
                FND_DISABLE(FND);
        }  

       
    //     if(Switch_read(GPIOB) == 1) {delay_time(TIM,100);  time_B_toggle = TIM_readCounter(TIM); }  // 버튼 누를때 시간 카운트 / toggle값이 0이 안되게 딜레이 
    //         //이타이밍에 떼야됨 
    //         if((Switch_read(GPIOB) ==0) && (TIM_readCounter(TIM) > time_B_toggle) ) {  //10초안에 눌러야함    // 버튼 누른시간보다 뒤에 꺼지면 실행행
    //             dht_odata = DHT11_run(DHT,TIM); //습도
    //             dht_RH_Int = (dht_odata >> 24) & 0xFF;
    //             dht_RH_Dec = (dht_odata >> 16) & 0xFF;
    //             dht_T_Int = (dht_odata  >> 8) & 0xFF;
    //             dht_T_Dec = dht_odata & 0xFF;
    //             temp_dht_RH_Int = dht_RH_Int;
    //             temp_dht_T_Int = dht_T_Int;
                
    //             for (int i=0; i<100;i++) {
    //                 dht_RH_Int += temp_dht_RH_Int;
    //                 dht_T_Int += temp_dht_T_Int;
    //             } // 곱하기 100
               
    //             TIM_clear(TIM); // 안눌렀을때 실행 안되게 초기화 
            
    //     }

    //     if((Switch_read(GPIOA)&(1<<0)) == (1<<0)) { //습습도
    //         FND_FONT(FND,dht_odata);
    //         FND_DOT(FND,1<<2);
    //         // tx에 보내기 함수
    //         }
    //     else if((Switch_read(GPIOA)&(1<<1)) == (1<<1)) { //온도도
    //         FND_FONT(FND, dht_T_Int+dht_T_Dec);
    //         FND_DOT(FND,1<<2);
    //         }
    // }
    if(RX_isFE(UART_RX) != 1) {
        if(RX_READ(UART_RX) == 's') { //계속 read_en 신호 나감 1번만 나가게 버튼 사용  // 배열로 미리 넘길 수 저장 
            dht_odata = DHT11_run(DHT,TIM);
            for (int i =0; i<4; i++) {
                temp_dht = (dht_odata >> *shift_num[3-i]) & 0xFF;
                tens = 0;
                ones = 0; // 매번 초기화 
                while(temp_dht >= 10) { //10의자리 1의자리 뽑아내기 */%못써서 이거씀 
                        temp_dht -= 10;
                        tens ++;
                }
                    ones = temp_dht;
                    
                    for(int j=0; j<2; j++) {
                        if(TX_isFE(UART_TX)!=(1 << 1) ){
                        TX_WRITE(UART_TX, (*ascii_num[j]) + '0');
                        tx_data = TX_READ(UART_TX);
                        TX_start(UART_TX,TIM);
                        FND_FONT(FND,tx_data & 0xFF);
                        delay_time(TIM,300000);
                         }
                    }
                    if((i ==0) || (i == 2)) {
                        if(TX_isFE(UART_TX)!=(1 << 1) ){
                            TX_WRITE(UART_TX, '.');
                            tx_data = TX_READ(UART_TX);
                            TX_start(UART_TX,TIM);
                            FND_FONT(FND,tx_data & 0xFF);
                            delay_time(TIM,300000);
                        }
                    }
                    else if((i ==1) || (i == 3)) {
                        if(TX_isFE(UART_TX)!=(1 << 1) ){
                            TX_WRITE(UART_TX, ' ');
                            tx_data = TX_READ(UART_TX);
                            TX_start(UART_TX,TIM);
                            FND_FONT(FND,tx_data & 0xFF);
                            delay_time(TIM,300000);
                        }
                    }
        
                 }
            }
         }   
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

uint32_t TX_isFE(UART_TX_TypeDef * TX) {
    return TX -> FFE;
}
uint32_t RX_isFE(UART_RX_TypeDef * RX) {
    return RX -> FFE;
}
void TX_WRITE(UART_TX_TypeDef *TX, char data) {
    TX -> FWD = (uint32_t)(data&0xFF);
}

uint32_t TX_READ(UART_TX_TypeDef *TX) {
    return TX -> FRD;
}

char RX_READ(UART_RX_TypeDef *RX) {

    return (char)((RX -> FRD) & 0xFF);}

void TX_start(UART_TX_TypeDef* TX,TIM_TypeDef *TIMx) {
    TX -> STR = (1<<0);
    delay_time(TIMx,10);
    TX -> STR = 0;
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

void TIM_init_1us(TIM_TypeDef *TIMx){
      TIM_writePsc(TIMx,100); //1us 틱 
      TIM_writeArr(TIMx,10000000); //10초까지 샘
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

void delay(int n){
    uint32_t temp;
    for(int j=0;j<500;j++) {
        for(int k=0;k < n; k++){
                temp++;
        }
    }
}