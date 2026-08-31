/// Bir tam sayıyı görüntülemek için binlik nokta ayraçlarıyla biçimlendirir
/// (₺20000 → "20.000"). Bu, TRY'ye özgü sabit gösterimler için (ör. PDF
/// export, F9-4 kapsamında salon para birimine göre değişecek); locale/para
/// birimine duyarlı girişler için `AppMoneyFormatter` kullanılır.
String formatThousands(int value) {
  final digits = value.abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    final indexFromEnd = digits.length - i;
    buffer.write(digits[i]);
    if (indexFromEnd > 1 && indexFromEnd % 3 == 1) buffer.write('.');
  }
  return value < 0 ? '-${buffer.toString()}' : buffer.toString();
}
