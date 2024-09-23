import 'dart:convert';
import 'package:http/http.dart' as http;

class ClaudeApiService {
  static const baseUrl = 'https://api.anthropic.com/v1/messages';
  static const apiKey = 'clave api Claude'; // Reemplaza con tu clave de API

  Future<Map<String, dynamic>> getDiagnosisAndTreatment(String symptoms, int age) async {
    final url = Uri.parse(baseUrl);
    final headers = {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
      'anthropic-version': '2023-06-01',
    };
    final body = json.encode({
      'model': 'claude-3-opus-20240229', 
      'system' : 'Respond only in Spanish.Hola, soy VIRGINIA, un sistema de inteligencia artificial desarrollado por Jose Quispe y Norín García en honor a Virginia Apgar, la anestesióloga que creó el test de Apgar para evaluar el estado de salud de los recién nacidos. Estoy especializada en enfermedades infantiles y mi objetivo es brindar orientación y recomendaciones generales, pero no reemplazar la atención médica profesional. Me enfocaré en ser amable, empática y cercana para que te sientas cómoda compartiendo los síntomas de tu hijo/a. Realizaré un diagnóstico preliminar basado en la información que me brindes y te daré recomendaciones sobre cómo proceder. Si se trata de una afección leve, te sugeriré algunos medicamentos de venta libre que podrían ayudar a aliviar los síntomas. Sin embargo, si detecto signos de una enfermedad más grave, te recomendaré buscar atención médica profesional de inmediato en tu centro de salud local como la MicroRed de salud Jerillo.Recuerda que, aunque haré mi mejor esfuerzo por orientarte, nunca reemplazaré el juicio experto de un médico capacitado. Mi rol es complementar, no sustituir, el cuidado médico adecuado. Estoy aquí para ayudarte a tomar decisiones informadas sobre la salud de tu hijo/a.Por favor, no dudes en compartir conmigo todos los detalles relevantes sobre los síntomas, la edad y el historial médico de tu pequeño/a. Estaré encantada de brindarte el mejor asesoramiento posible. Nota: Tu respuesta tiene que ser lo mas corta posible, indicando solo lo necesario',
      'max_tokens': 1024,
      'messages': [
        {
          'role': 'user',
          'content': 'Symptoms: $symptoms, Age: $age {{#if $symptoms.includes(hola) || $symptoms.includes(gracias) || $symptoms.includes(buenos días) || $symptoms.includes(buenas tardes) || $symptoms.includes(buenas noches)}}Responde de manera amable y cortés, según la situación. Por ejemplo:- "¡Hola! Es un placer atenderle. ¿En qué puedo ayudarle hoy?"- "Gracias a usted por contactarnos. ¿Cuáles son los síntomas que está experimentando?"- "Buenos días/tardes/noches. Estoy aquí para brindarle atención y ayudarle con sus síntomas. Por favor, descríbalos." "Si es gracias puedes responder: De nada, es un placer poder ayudarte. Por favor, siéntete libre de compartir los detalles de tus síntomas para que pueda brindarte la mejor recomendación posible."{{else}} Continuar con la conversación de manera apropiada según los síntomas y la edad proporcionados, brindando recomendaciones médicas o sugiriendo consultar con un profesional de la salud si es necesario.{{/if}}',       
          }
      ],
    });

    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      print(response.body); // Imprime la respuesta completa de la API

      // Decodificar la respuesta con la codificación UTF-8
      final decodedResponse = json.decode(utf8.decode(response.bodyBytes));
      return decodedResponse;
    } else {
      print('Error al obtener el diagnóstico y tratamiento: ${response.statusCode} - ${response.body}');
      throw Exception('Error al obtener el diagnóstico y tratamiento');
    }
  }
}
