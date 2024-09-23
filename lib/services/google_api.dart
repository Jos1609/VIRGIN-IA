import 'package:google_generative_ai/google_generative_ai.dart';

class GoogleGenerativeApiService {
  Future<Map<String, dynamic>> getDiagnosisAndTreatment(String userInput, int age) async {
    // Accede a tu clave API como una variable de entorno
    const apiKey = 'tu api google gemini';

    // Inicializa el modelo generativo
    final model = GenerativeModel(
      model: 'gemini-1.5-pro',
      apiKey: apiKey,
      generationConfig: GenerationConfig(
        temperature: 1.0,
        topK: 64,
        topP: 0.95,
        maxOutputTokens: 8192,
        responseMimeType: 'text/plain',
      ),
    );

    // Configura el mensaje del sistema
   final systemInstruction = Content.text(
  'Respond only in Spanish.Hola, soy VIRGIN-IA, un sistema de inteligencia artificial desarrollado por Jose Quispe y Norín García en honor a Virginia Apgar, la anestesióloga que creó el test de Apgar para evaluar el estado de salud de los recién nacidos. Estoy especializada en enfermedades infantiles y mi objetivo es brindar orientación y recomendaciones generales, pero no reemplazar la atención médica profesional. Me enfocaré en ser amable, empática y cercana para que te sientas cómoda compartiendo los síntomas de tu hijo/a. Realizaré un diagnóstico preliminar basado en la información que me brindes y te daré recomendaciones sobre cómo proceder. Si se trata de una afección leve, te sugeriré algunos medicamentos de venta libre que podrían ayudar a aliviar los síntomas. Sin embargo, si detecto signos de una enfermedad más grave, te recomendaré buscar atención médica profesional de inmediato en tu centro de salud local como la MicroRed de salud Jerillo.Recuerda que, aunque haré mi mejor esfuerzo por orientarte, nunca reemplazaré el juicio experto de un médico capacitado. Mi rol es complementar, no sustituir, el cuidado médico adecuado. Estoy aquí para ayudarte a tomar decisiones informadas sobre la salud de tu hijo/a.Por favor, no dudes en compartir conmigo todos los detalles relevantes sobre los síntomas, la edad y el historial médico de tu pequeño/a. Estaré encantada de brindarte el mejor asesoramiento posible.',
);

    // Inicializa el chat
    final chat = model.startChat(history: [systemInstruction]);

    // Verifica si el usuario ingresó síntomas
    if (userInput.toLowerCase().contains('síntomas')) {
      // Extrae los síntomas del mensaje del usuario
      final symptoms = _extractSymptoms(userInput);

      // Configura el contenido del usuario
      final content = Content.text('Symptoms: $symptoms, Age: $age, ');

      // Envía el mensaje y obtiene la respuesta
      try {
        final response = await chat.sendMessage(content);
        print(response.text);
        return {'text': response.text};
      } catch (e) {
        print('Error al obtener el diagnóstico y tratamiento: $e');
        return {'error': 'Error al obtener el diagnóstico y tratamiento: $e'};
      }
    } else {
      // Si el usuario no ingresó síntomas, manejamos el caso especial
      final response = await chat.sendMessage(Content.text(userInput));
      print(response.text);
      return {'text': response.text};
    }
  }

  // Función para extraer los síntomas del mensaje del usuario
  String _extractSymptoms(String userInput) {
    // Patrón de expresión regular para buscar los síntomas
    final symptomPattern = RegExp(r'síntomas:\s*(.*)', caseSensitive: false);

    // Busca los síntomas en el mensaje del usuario
    final match = symptomPattern.firstMatch(userInput);

    // Si se encuentra una coincidencia, extrae los síntomas
    if (match != null && match.groupCount >= 1) {
      return match.group(1)?.trim() ?? '';
    }

    // Si no se encuentran síntomas, devuelve una cadena vacía
    return '';
  }
}