String getSky(String code) {
  switch (code) {
    case '1':
      return '맑음';
    case '3':
      return '구름많음';
    case '4':
      return '흐림';
    default:
      return '-';
  }
}

String getPty(String code) {
  switch (code) {
    case '0':
      return '없음';
    case '1':
      return '비';
    case '2':
      return '비/눈';
    case '3':
      return '눈';
    case '4':
      return '소나기';
    default:
      return '-';
  }
}

String getSkyEmoji(String code) {
  switch (code) {
    case '1':
      return '☀️';
    case '3':
      return '⛅';
    case '4':
      return '☁️';
    default:
      return '❓';
  }
}
