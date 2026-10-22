# Egoractive — release (R8) kuralları.
#
# SORUN: Uygulama Play'den TEMİZ KURULUMDA açılmadan çöküyordu (siyah ekran
# sonra crash, 2026-09-05 kapalı test raporu). Yığın izi:
#
#   Unable to get provider androidx.startup.InitializationProvider:
#     java.lang.RuntimeException:
#       Failed to create an instance of androidx.work.impl.WorkDatabase
#
# SEBEP: AGP 8 ile R8 "full mode" varsayılan olarak AÇIK. Room, veritabanı
# sınıfının derleme zamanında üretilen `_Impl` karşılığını YANSIMAYLA
# (Class.forName + newInstance) örnekliyor. Full mode, sınıfın kendisini
# koruyor ama hiçbir yerden ÇAĞRILMADIĞI için parametresiz kurucusunu
# siliyor — sınıf var, örneği yaratılamıyor.
#
# WorkManager'ı doğrudan biz kullanmıyoruz; `google_mobile_ads` (AdMob)
# bağımlılığı getiriyor ve `androidx.startup` sağlayıcısı uygulama açılışında,
# Flutter motoru başlamadan ÖNCE çalıştığı için hata ölümcül oluyordu.
#
# NEDEN MEVCUT KURULUMLARDA GÖRÜNMÜYORDU: WorkManager veritabanı yalnızca
# İLK açılışta oluşturuluyor. Uygulamayı üzerine güncelleyen cihazlarda veri
# tabanı zaten vardı, o yüzden çökme yalnızca temiz kurulumlarda (yani
# testerların yaptığı kurulumda) ortaya çıkıyordu.

# Room'un ürettiği tüm *_Impl sınıflarının parametresiz kurucusunu koru.
-keep class * extends androidx.room.RoomDatabase { <init>(); }

# WorkManager'ın kendi Room veritabanı — yukarıdaki kural bunu zaten
# kapsıyor, ama hatanın tam olarak çıktığı sınıf olduğu için açıkça yazıldı.
-keep class androidx.work.impl.WorkDatabase_Impl { <init>(); }

# Room, migration ve otomatik migration sınıflarını da yansımayla kuruyor.
-keep class * extends androidx.room.migration.Migration { <init>(...); }
