//fsm식으로 

int main(){

    LED_init(GPIOC);
    Switch_init(GPIOD);
    uint32_t state = FUNC1;
    while(1) {
        switch(state){
            case FUNC1:
                func1();
            break;
            case FUNC2:
            func2();
            break;
            case FUNC3:
            func3();
            break;
            case FUNC4:
            func4();
            break;
        }
        switch(state){
            case FUNC1:
                if(Button_getState(GPIOD) & (1 << BUTTON_2)) state = FUNC2;
                else if(Button_getState(GPIOD) & (1 << BUTTON_3)) state = FUNC3;
                else if(Button_getState(GPIOD) & (1 << BUTTON_4)) state = FUNC4;
                else state = FUNC1;

            break;
            case FUNC2:
            if(Button_getState(GPIOD) & (1 << BUTTON_1)) state = FUNC1;
            else if(Button_getState(GPIOD) & (1 << BUTTON_3)) state = FUNC3;
            else if(Button_getState(GPIOD) & (1 << BUTTON_4)) state = FUNC4;
            else state = FUNC2;
            break;
            case FUNC3:
            if(Button_getState(GPIOD) & (1 << BUTTON_1)) state = FUNC1;
            else if(Button_getState(GPIOD) & (1 << BUTTON_2)) state = FUNC2;
            else if(Button_getState(GPIOD) & (1 << BUTTON_4)) state = FUNC4;
            else state = FUNC3;
            break;
            case FUNC4:
            if(Button_getState(GPIOD) & (1 << BUTTON_1)) state = FUNC1;
            else if(Button_getState(GPIOD) & (1 << BUTTON_2)) state = FUNC2;
            else if(Button_getState(GPIOD) & (1 << BUTTON_3)) state = FUNC3;
            else state = FUNC4;
            break;

    }

}

void func1(){
    static uint32_t prevTime = 0;
    uint32_t curTime =  = TIM_readCounter(TIM0);
    if(curTime - prevTime < 200) return;
    prevTime = curTime;

    static uint32_t func1Data = 0;
    fundc1Data ^= 1 << 1;
    LED_write(GPIOD,func1Data);
}

void func2(){
    static uint32_t prevTime = 0;
    uint32_t curTime =  = TIM_readCounter(TIM0);
    if(curTime - prevTime < 500) return;
    prevTime = curTime;

    static uint32_t func2Data = 0;
    fundc2Data ^= 1 << 1;
    LED_write(GPIOD,func2Data);
       
}

void func3(){
    static uint32_t prevTime = 0;
    uint32_t curTime =  = TIM_readCounter(TIM0);
    if(curTime - prevTime < 1000) return;
    prevTime = curTime;

    static uint32_t func3Data = 0;
    fundc3Data ^= 1 << 2;
    LED_write(GPIOD,func3Data);
       
}

void func4(){
    static uint32_t prevTime = 0;
    uint32_t curTime =  = TIM_readCounter(TIM0);
    if(curTime - prevTime < 1500) return;
    prevTime = curTime;

    static uint32_t func4Data = 0;
    fundc4Data ^= 1 << 3;
    LED_write(GPIOD,func4Data);
       
}

void power(){
    static uint32_t prevTime = 0;
    uint32_t curTime =  = TIM_readCounter(TIM0);
    if(curTime - prevTime < 500) return;
    prevTime = curTime;

    static uint32_t func4Data = 0;
    fundc4Data ^= 1 << 0;
    LED_write(GPIOD,func4Data);
}