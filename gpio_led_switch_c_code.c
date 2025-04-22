#include <stdint.h>

#define __IO volatile

typedef struct{
    __IO uint32_t MODER;
    __IO uint32_t IDR;
    __IO uint32_t ODR;
} GPIO_TypeDef;

// typedef struct{
//     __IO uint32_t MODER;
//     __IO uint32_t IDR;
// } GPI_TypeDef;

#define APB_BASEADDR 0x10000000
#define GPIO_BASEADDR (APB_BASEADDR + 0x1000)
// #define GPIB_BASEADDR (APB_BASEADDR + 0x2000)

#define GPIO ((GPIO_TypeDef *) GPIO_BASEADDR)


// #define GPOA_MODER  *(uint32_t *)(GPOA_BASEADDR + 0x00)
// #define GPOA_ODR    *(uint32_t *)(GPOA_BASEADDR + 0x04)
// #define GPIB_MODER  *(uint32_t *)(GPIB_BASEADDR + 0x00)
// #define GPIB_IDR    *(uint32_t *)(GPIB_BASEADDR + 0x04)


void delay(int n);

void LED_init(GPIO_TypeDef *GPIOx);
void LED_write(GPIO_TypeDef *GPIOx, uint32_t data);
void Switch_init(GPIO_TypeDef *GPIOx);
uint32_t Switch_read(GPIO_TypeDef *GPIOx);

int main()
{
    // GPOA_MODER = 0xff;  // output mode
    // GPIB_MODER = 0x00; // input mode
    // GPOA_ODR = 1;
    // GPOA -> MODER = 0xff;
    // GPIB -> MODER = 0x00;
    // LED_init(GPIO);
    // Switch_init(GPIO);
    
    uint32_t temp;
    uint32_t one = 1;
    while(1)
    {   
        Switch_init(GPIO); //읽기모드
        temp = Switch_read(GPIO);
        if(temp & (1<<0)){ //첫번쨰  스위치
            LED_init(GPIO); //쓰기모드
            LED_write(GPIO, temp);
        }
        else if(temp & (1<<1)){ // 2번쨰 스위치 
            LED_init(GPIO);
            LED_write(GPIO, one);
            one = (one << 1) | (one >> 7); // 왼쪽 순환 msb를 lsb로
            delay(500);
        }
        else if(temp & (1<<2)){ // 오른쪽 순환 lsb를 msb로 
            LED_init(GPIO);
            LED_write(GPIO, one); //3번쨰 스위치 
            one = (one >> 1) | (one << 7);
            delay(500);
        }
        else{
            LED_init(GPIO);
            LED_write(GPIO, 0xff); // 나머지 
            delay(500);
            LED_write(GPIO, 0x00);
            delay(500);
        }

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
    GPIOx->MODER = 0xff;
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