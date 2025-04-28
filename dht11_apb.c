#include <stdint.h>

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
    __IO uint32_t FWD; //fifo write data
    __IO uint32_t FRD; //fifo read data
} FIFO_TypeDef;

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
#define GPIOC_BASEADDR (APB_BASEADDR + 0x3000)//3
// #define GPIOD_BASEADDR (APB_BASEADDR + 0x4000)//4
#define DHT_BASEADDR (APB_BASEADDR + 0x4000) //psel4
#define FND_BASEADDR (APB_BASEADDR + 0x5000) //psel5
#define FIFO_BASEADDR (APB_BASEADDR + 0x6000) //psel6
#define TIM_BASEADDR (APB_BASEADDR + 0x7000) //psel6


#define GPIOA ((GPIO_TypeDef *) GPIOA_BASEADDR)
#define GPIOB ((GPIO_TypeDef *) GPIOB_BASEADDR)
#define GPIOC ((GPIO_TypeDef *) GPIOC_BASEADDR)
// #define GPIOD ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define DHT ((DHT_TypeDef *) DHT_BASEADDR)
#define FND ((FND_TypeDef *) FND_BASEADDR)
#define FIFO ((FIFO_TypeDef *) FIFO_BASEADDR)

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

uint32_t FIFO_isFE(FIFO_TypeDef *FIFOx); //return uint32_t
void FIFO_WRITE(FIFO_TypeDef *FIFOx, uint32_t data);
uint32_t FIFO_READ(FIFO_TypeDef *FIFOx);

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

void DHT_start(DHT_TypeDef * DHTx);
void DHT_stop(DHT_TypeDef * DHTx);
uint32_t read_DHT(DHT_TypeDef * DHTx);
uint32_t read_DONE(DHT_TypeDef *DHTx);
uint32_t read_CHK(DHT_TypeDef *DHTx);


void TIM_init_1us(TIM_TypeDef * TIMx);
void delay(int n);

uint32_t DHT11_run(DHT_TypeDef * DHTx,TIM_TypeDef *TIMx);
//0.1초 10**7

int main()
{

    // uint32_t fmr_num =1 ;
    // uint32_t fdr_num =0 ;
    Switch_init(GPIOA);
    // uint32_t count;
    // uint32_t fifo_read;
    // LED_init(GPIOC);
    // uint32_t temp_switch;
    // uint32_t one = 1;
    // FND_COMM(FND,0x00f);
    // FND_DOT(FND,1<<0);
    //  if(FIFO_isFE(FIFO) != 0x10) {
    //             FIFO_WRITE(FIFO,1);
    //       }
    // if(FIFO_isFE(FIFO) != 0x01) {
    //             fifo_read = FIFO_READ(FIFO);
    //       }
        // TIM_clear(TIM);
        // TIM_writePsc(TIM,1000);
        // TIM_writeArr(TIM,100);
        // TIM_start(TIM);

        // temp_switch = power_led(GPIOC,GPIOA); //초기상태
        // uint32_t current_time;
        // TIM_writePsc(TIM,100); //1us
        // TIM_writeArr(TIM,10000);
      uint32_t dht_odata;
      uint32_t dht_RH_Int;
      uint32_t dht_RH_Dec;
      uint32_t dht_T_Int;
      uint32_t dht_T_Dec;

    TIM_init_1us(TIM);



     while(1)
  {      
    // TIM_init(TIM);
    
   

        // temp_switch = Switch_read(GPIOA);
    

            

      //습도
            
            
          
           

           
        
        if((Switch_read(GPIOA) & (1<<2)) == (1 << 2)) {
                FND_ENABLE(FND);
        }        else {
                FND_DISABLE(FND);
        }  

        if((Switch_read(GPIOA)&(1<<0)) == (1<<0)) { //모드
            if(Switch_read(GPIOB) == 1) {//런런
            dht_odata = DHT11_run(DHT,TIM); //습도
            dht_RH_Int = dht_odata >> 24;
            dht_RH_Dec = (dht_odata >> 16) & (0xff);
            // for (int i=0; i<100;i++) {
            //     dht_RH_Int += dht_RH_Int;
            // } // 곱하기 100

            FND_FONT(FND,dht_RH_Int);
            FND_DOT(FND,1<<2);
            // tx에 보내기 함수
            }
        }

        else if((Switch_read(GPIOA)&(1<<1)) == (1<<1)) { //모드드
            if(Switch_read(GPIOB) == 1) {//런
            dht_odata = DHT11_run(DHT,TIM); //온온도
            dht_T_Int = (dht_odata) & (0xff << 8);
            dht_T_Dec = (dht_odata) & (0xff);
            // for (int i=0; i<100;i++) {
            //     dht_T_Int += dht_T_Int;
            // } // 곱하기 100

            FND_FONT(FND, dht_T_Int );
            FND_DOT(FND,1<<2);
        }
            // tx에 보내기 함수
        }




        //      if(temp_switch== (1<<0)) {temp_switch = btn1_led(GPIOC,GPIOA);}
        // else if(temp_switch== (1<<1)) {temp_switch = btn2_led(GPIOC,GPIOA);}
        // else if(temp_switch== (1<<2)) {temp_switch = btn3_led(GPIOC,GPIOA);}
        // else if(temp_switch== (1<<3)) {temp_switch = btn4_led(GPIOC,GPIOA);}
        // else temp_switch = power_led(GPIOC,GPIOA);

        // if(FIFO_isFE(FIFO) != (1<<1)) {
        //     FIFO_WRITE(FIFO,count);
        //     }

        //  if(FIFO_isFE(FIFO) != 1) {
        //     fifo_read = FIFO_READ(FIFO);
        //   }


        //   if(count == 9999) { count = 0;}



        // for(int i =0;i<2000; i++) {
        //     current_time = TIM_readCounter(TIM);
        //      FND_FONT(FND,current_time);
        //     delay(100);
        // }
        
          
        // FND_FONT(FND,TIM_readCounter(TIM));
        // // delay(1);
        // FND_DOT(FND,1<<0);
        // delay(300);
        // FND_DOT(FND,0<<0);
        // delay(300);
        // count += 1; 
        
     


        // count += 1;
        // FND_FONT(FND,count);
        // delay(10000);


        // if(temp & (1<<0)){ //첫번쨰  스위치
        //     LED_init(GPIO); //쓰기모드
        //     LED_write(GPIO, temp);
        // }
        // else if(temp & (1<<1)){ // 2번쨰 스위치 
        //     LED_init(GPIO);
        //     LED_write(GPIO, one);
        //     one = (one << 1) | (one >> 7); // 왼쪽 순환 msb를 lsb로
        //     delay(500);
        // }
        // else if(temp & (1<<2)){ // 오른쪽 순환 lsb를 msb로 
        //     LED_init(GPIO);
        //     LED_write(GPIO, one); //3번쨰 스위치 
        //     one = (one >> 1) | (one << 7);
        //     delay(500);
        // }
        // else{
        //     LED_init(GPIO);
        //     LED_write(GPIO, 0xff); // 나머지 
        //     delay(500);
        //     LED_write(GPIO, 0x00);
        //     delay(500);
        // }

        //GPOA_ODR = GPIB_IDR;
        // GPOA->ODR = GPIB->IDR;
        // GPOA_ODR = GPOA_ODR << 1 | (GPOA_ODR >> 7);
        // delay(500);
        //GPOA_ODR = 0x00;
        //delay(500);



    }
    return 0;
}
//10000000 -> 0.1초 틱 
void delay_time(TIM_TypeDef *TIMx, uint32_t limit_time)
{   
            TIM_clear(TIMx);
    while(TIM_readCounter(TIMx) < limit_time){
            TIM_start(TIMx);       
    } 
}

uint32_t power_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy) {
        uint32_t temp = 0;
        TIM_writePsc(TIM,10000000); //0.1초
        TIM_writeArr(TIM,100); //0.5초
        while(temp == 0) {
        LED_write(GPIOx,(1 << 3 ));
        delay_time(TIM,6); //0.5초
        LED_write(GPIOx,0);
        delay_time(TIM,6);
        temp = Switch_read(GPIOy);
        }
        return temp;
}

uint32_t btn1_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy) {
    uint32_t temp = 0;
        TIM_writePsc(TIM,10000000); //0.1초
        TIM_writeArr(TIM,100); //0.5초
        while(temp == 0) {
        LED_write(GPIOx,(1 << 2 ));
        delay_time(TIM,3); //0.5초
        LED_write(GPIOx,0);
        delay_time(TIM,3);    
        temp = Switch_read(GPIOy);
        }
        return temp;
}

uint32_t btn2_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy) {
    uint32_t temp = 0;
        TIM_writePsc(TIM,10000000); //0.1초
        TIM_writeArr(TIM,100); //0.5초
        while(temp == 0){
        LED_write(GPIOx,(1 << 1 ));
        delay_time(TIM,6); //0.5초
        LED_write(GPIOx,0);
        delay_time(TIM,6);
        temp = Switch_read(GPIOy);
}
    return temp;
}


uint32_t btn3_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy) {
    uint32_t temp = 0;
        TIM_writePsc(TIM,10000000); //0.1초
        TIM_writeArr(TIM,100); //0.5초
        while(temp == 0){
        LED_write(GPIOx,(1 << 0 ));
        delay_time(TIM,11); //0.5초
        LED_write(GPIOx,0);
        delay_time(TIM,11);
        temp = Switch_read(GPIOy);
        }
    return temp;
}


uint32_t btn4_led(GPIO_TypeDef* GPIOx,GPIO_TypeDef* GPIOy) {
        uint32_t temp = 0;
        TIM_writePsc(TIM,10000000); //0.1초
        TIM_writeArr(TIM,100); //0.5초
        while(temp == 0){
        LED_write(GPIOx,7);
        delay_time(TIM,16); //0.5초
        LED_write(GPIOx,0);
        delay_time(TIM,16);
        temp = Switch_read(GPIOy);
}
        return temp;
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

uint32_t FIFO_isFE(FIFO_TypeDef *FIFOx) {
    return FIFOx -> FFE;
}

void FIFO_WRITE(FIFO_TypeDef *FIFOx, uint32_t data) {
    FIFOx -> FWD = data;
}

uint32_t FIFO_READ(FIFO_TypeDef *FIFOx) {
    return FIFOx -> FRD;
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
void DHT_start(DHT_TypeDef * DHTx){ //한번번
    DHTx -> STR = (1 << 0);
    DHTx -> STR = (0 << 0);
}
void DHT_stop(DHT_TypeDef * DHTx){
    DHTx -> STR = (0 << 0);
}
uint32_t read_DHT(DHT_TypeDef * DHTx){
    return DHTx -> DOR;
}
uint32_t read_DONE(DHT_TypeDef *DHTx){
    return ((DHT -> DCR) >> 1);
}
uint32_t read_CHK(DHT_TypeDef *DHTx){
     return ((DHT -> DCR) & ~(1 << 1));
}

void TIM_init_1us(TIM_TypeDef *TIMx){
      TIM_writePsc(TIMx,100);
      TIM_writeArr(TIMx,100000);
} // 1us 정하기 

uint32_t DHT11_run(DHT_TypeDef * DHTx,TIM_TypeDef *TIMx){
    // if(read_DONE(DHTx) == 1) {
        DHT_start(DHTx);
        delay_time(TIMx,10000); //10ms 대기
        if(read_CHK(DHTx) == 1) {
            return read_DHT(DHTx);
        }
        else return 123456789;
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