from rest_framework import serializers

from .models import LocationUpdate


class LocationSerializer(serializers.ModelSerializer):
    class Meta:
        model = LocationUpdate
        fields = ["id", "child", "lat", "lng", "address", "battery", "active", "created_at"]
        read_only_fields = ["id", "child", "created_at"]


class LocationInputSerializer(serializers.Serializer):
    lat = serializers.FloatField()
    lng = serializers.FloatField()
    address = serializers.CharField(required=False, allow_blank=True, default="")
    battery = serializers.IntegerField(required=False, allow_null=True)
    active = serializers.BooleanField(required=False, default=True)
