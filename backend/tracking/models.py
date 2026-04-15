from django.conf import settings
from django.db import models


class LocationUpdate(models.Model):
    child = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="locations",
    )
    lat = models.FloatField()
    lng = models.FloatField()
    address = models.CharField(max_length=255, blank=True)
    battery = models.IntegerField(null=True, blank=True)
    active = models.BooleanField(default=True)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ["-created_at"]

    def __str__(self):
        return f"{self.child.username} @ {self.lat:.4f},{self.lng:.4f}"
