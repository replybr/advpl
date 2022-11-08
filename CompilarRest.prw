User Function StartRest()

  StartJob("HTTP_START", GetEnvServer(), .f.)

  Sleep(7500)

  Alert(">> Serviço REST inicializado. <<")

Return()