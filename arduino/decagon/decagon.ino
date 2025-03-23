#if 1

// (c) Michael Schoeffler 2017, http://www.mschoeffler.de
#include <Stepper.h>
#define STEPS 2038 // the number of steps in one revolution of your motor (28BYJ-48)
Stepper stepper(STEPS, 8, 10, 9, 11);
void setup() {
  // nothing to do
}
void loop() {
//      stepper.setSpeed(1); // 1 rpm
//      stepper.step(2038); // do 2038 steps -- corresponds to one revolution in one minute

  powerOff();
  delay(1000); // wait for one second
  stepper.setSpeed(10); // rpm
  stepper.step(-2048); // do 2038 steps in the other direction with faster speed 
}

// whaddaya say we shut off the motor when we are not using it?
void powerOff()
{
  digitalWrite(8, LOW);
  digitalWrite(9, LOW);
  digitalWrite(10, LOW);
  digitalWrite(11, LOW);
}


#else




#define IN1 8
#define IN2 9
#define IN3 10
#define IN4 11
int Steps = 0;
boolean Direction = true;


//#define DLY 800
#define DLY 800


void setup() 
{
  Serial.begin(9600);
  pinMode(IN1, OUTPUT);
  pinMode(IN2, OUTPUT);
  pinMode(IN3, OUTPUT);
  pinMode(IN4, OUTPUT);
}
void loop() {
  for(int i=0; i<4096; i++)
  {
    stepper(1);
    delayMicroseconds(DLY);
  }
  //Direction = !Direction;
  delay(1000);
}

void stepper(int xw) 
{
  for (int x = 0; x < xw; x++) 
  {
    switch (Steps) 
    {
    case 0:
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, HIGH);
    break;
    case 1:
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, HIGH);
    break;
    case 2:
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, LOW);
    break;
    case 3:
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    digitalWrite(IN3, HIGH);
    digitalWrite(IN4, LOW);
    break;
    case 4:
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, HIGH);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, LOW);
    break;
    case 5:
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, HIGH);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, LOW);
    break;
    case 6:
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, LOW);
    break;
    case 7:
    digitalWrite(IN1, HIGH);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, HIGH);
    break;
    default:
    digitalWrite(IN1, LOW);
    digitalWrite(IN2, LOW);
    digitalWrite(IN3, LOW);
    digitalWrite(IN4, LOW);
    break;
    }
  
    SetDirection();
  }
}

  
void SetDirection() 
{
  if (Direction == 1) 
  {
    Steps++;
  }
  if (Direction == 0) 
  {
    Steps--;
  }
  if (Steps > 7) 
  {
    Steps = 0;
  }
  if (Steps < 0) 
  {
    Steps = 7;
  }
} 

#endif
