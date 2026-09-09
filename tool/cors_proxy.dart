import 'dart:io';

/// Forwards Flutter web calls to https://api.kozzy.online with CORS headers
/// so any localhost port can load the live catalog.
void main() async {
  const port = 8099;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('Kozzy API proxy  http://127.0.0.1:$port  ->  https://api.kozzy.online');

  await for (final request in server) {
    await _forward(request);
  }
}

void _applyCors(HttpResponse response, String origin) {
  response.headers
    ..set('Access-Control-Allow-Origin', origin)
    ..set('Access-Control-Allow-Methods', 'GET,POST,PUT,PATCH,DELETE,OPTIONS')
    ..set('Access-Control-Allow-Headers', 'Content-Type, Accept, token')
    ..set('Access-Control-Allow-Credentials', 'true')
    ..set('Vary', 'Origin');
}

Future<void> _forward(HttpRequest request) async {
  final origin = request.headers.value('origin') ?? '*';
  final response = request.response;

  if (request.method == 'OPTIONS') {
    _applyCors(response, origin);
    response.statusCode = HttpStatus.noContent;
    await response.close();
    return;
  }

  final client = HttpClient();
  try {
    final target = Uri.https('api.kozzy.online', request.uri.path, request.uri.queryParameters.isEmpty
        ? null
        : request.uri.queryParameters);
    final proxyReq = await client.openUrl(request.method, target);
    request.headers.forEach((name, values) {
      final key = name.toLowerCase();
      if (key == 'host' ||
          key == 'origin' ||
          key == 'referer' ||
          key == 'content-length' ||
          key == 'accept-encoding') {
        return;
      }
      for (final value in values) {
        proxyReq.headers.add(name, value);
      }
    });
    proxyReq.headers.set(HttpHeaders.acceptEncodingHeader, 'identity');
    await proxyReq.addStream(request);
    final proxyRes = await proxyReq.close();

    response.statusCode = proxyRes.statusCode;
    _applyCors(response, origin);
    proxyRes.headers.forEach((name, values) {
      final key = name.toLowerCase();
      if (key.startsWith('access-control-') ||
          key == 'transfer-encoding' ||
          key == 'content-encoding') {
        return;
      }
      for (final value in values) {
        response.headers.add(name, value);
      }
    });
    await response.addStream(proxyRes);
  } catch (error) {
    _applyCors(response, origin);
    response.statusCode = HttpStatus.badGateway;
    response.headers.contentType = ContentType.json;
    response.write('{"success":false,"message":"${error.toString().replaceAll('"', "'")}"}');
  } finally {
    await response.close();
    client.close(force: true);
  }
}
