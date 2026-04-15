from django.contrib import admin

from .models import LocationUpdate


@admin.register(LocationUpdate)
class LocationUpdateAdmin(admin.ModelAdmin):
    list_display = ("child", "lat", "lng", "address", "battery", "active", "created_at")
    list_filter = ("active", "child")
    search_fields = ("child__username", "address")
