#include <stdint.h>

#define __IO volatile // 최적화없이 있는 그대로 값 사용 
typedef struct{
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
} GPIO_TypeDef;

typedef struct{
    __IO uint32_t FCR;
    __IO uint32_t FDR;
    __IO uint32_t FPR;
} FND_TypeDef;


#define APB_BASEADDR 0x10000000 //0
#define GPIOA_BASEADDR (APB_BASEADDR + 0x1000)//1
#define GPIOB_BASEADDR (APB_BASEADDR + 0x2000)//2
#define GPIOC_BASEADDR (APB_BASEADDR + 0x3000)//3
#define GPIOD_BASEADDR (APB_BASEADDR + 0x4000)//4
#define FND_BASEADDR (APB_BASEADDR + 0x5000) //psel5


#define GPIOA ((GPIO_TypeDef *) GPIOA_BASEADDR)
#define GPIOB ((GPIO_TypeDef *) GPIOB_BASEADDR)
#define GPIOC ((GPIO_TypeDef *) GPIOC_BASEADDR)
#define GPIOD ((GPIO_TypeDef *) GPIOD_BASEADDR)
#define FND ((FND_TypeDef *) FND_BASEADDR)


void delay(int n);

void LED_init(GPIO_TypeDef *GPIOx);

void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);

void Switch_init(GPIO_TypeDef *GPIOx);

uint32_t Switch_read(GPIO_TypeDef *GPIOx);




void FND_ENABLE(FND_TypeDef *FNDx);
void FND_DISABLE(FND_TypeDef *FNDx);
void FND_COMM(FND_TypeDef *FNDx, uint32_t data);
void FND_FONT(FND_TypeDef *FNDx, uint32_t data);
void FND_DOT(FND_TypeDef *FNDx, uint32_t data);




int main()
{

    uint32_t fmr_num =1 ;
    uint32_t fdr_num =0 ;
    Switch_init(GPIOA);
    uint32_t count = 0;
    // uint32_t one = 1;
    // FND_COMM(FND,0x00f);
    // FND_DOT(FND,1<<0);
     while(1)
  {     
          if(count == 9999) { count = 0;}

          if(Switch_read(GPIOA) == 1) {
         FND_ENABLE(FND);
 }        else {
         FND_DISABLE(FND);
 }    

        // for(fmr_num =1;fmr_num<16; fmr_num++) {
        //     for(fdr_num =0; fdr_num < 10; fdr_num++) {
        //         FND_COMM(FND,fmr_num);
        //         FND_FONT(FND,fdr_num);
        //         delay(100000);
        //     }
        //     delay(100000);
        // }

        FND_FONT(FND,count);
        // delay(1);
        FND_DOT(FND,1<<0);
        delay(100);
        FND_DOT(FND,0<<0);
        delay(100);
        count += 1; 
        
     


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

void delay(int n)
{
    uint32_t temp = 0;
    for(int i=0; i < n; i++){
        for(int j=0; j < 500; j++){
            temp ++;
        }
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
