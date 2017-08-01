#include <ESP8266WiFi.h>

const char* ssid     = "jelber";
const char* password = "12345678";
const char* host = "www.erradicazica.com";
boolean estado = true;
int pino = 5;
int pinoleitura = 4;
void conectar()
{
  Serial.begin(115200);
  delay(10);

  Serial.println();
  Serial.println();
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
  }
}

void setup() {
  pinMode(pino,OUTPUT);
  pinMode(pinoleitura,INPUT);
  conectar();
  
}

void verificar_status()
{

  WiFiClient client;
  const int httpPort = 80;
  if (!client.connect(host, httpPort)) {
    Serial.println("connection failed");
    return;
  }

  String url = "/pedro/leitura.rkt";
  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" +
               "Connection: close\r\n\r\n");
  unsigned long timeout = millis();
  while (client.available() == 0) {
    if (millis() - timeout > 5000) {
      Serial.println(">>> Client Timeout !");
      client.stop();
      return;
    }
  }
  while (client.available()) {
    String line = client.readStringUntil('\r');
    if (line.indexOf("ligado") != -1)
    {
      estado = true;
    }
    if (line.indexOf("desligado") != -1)
    {
      estado = false;
    }

  }
}
void GET()
{
  WiFiClient client;
  const int httpPort = 80;
  if (!client.connect(host, httpPort)) {
    Serial.println("connection failed");
    return;
  }

  String url = "/pedro/leitura.rkt?appnew";

  Serial.print("Requesting URL: ");
  Serial.println(url);
  client.print(String("GET ") + url + " HTTP/1.1\r\n" +
               "Host: " + host + "\r\n" +
               "Connection: close\r\n\r\n");
  unsigned long timeout = millis();
  while (client.available() == 0) {
    if (millis() - timeout > 5000) {
      Serial.println(">>> Client Timeout !");
      client.stop();
      return;
    }
  }
  while (client.available()) {
    String line = client.readStringUntil('\r');
    if (line.indexOf("ligado") != -1)
    {
      estado = true;
    }
    if (line.indexOf("desligado") != -1)
    {
      estado = false;
    }

  }
  Serial.println("closing connection");
}

void controle()
{
  if(estado)
  {
    digitalWrite(pino,HIGH);
  }
  else
  {
    digitalWrite(pino,LOW);
  }
}

void loop() {
 if(digitalRead(pinoleitura) == 1)
 {
  delay(250);
  GET();
 }
 controle();
 Serial.println(digitalRead(pinoleitura));

}

