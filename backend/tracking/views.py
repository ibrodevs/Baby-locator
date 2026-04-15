from django.shortcuts import get_object_or_404
from rest_framework.response import Response
from rest_framework.views import APIView

from accounts.models import User

from .models import LocationUpdate
from .serializers import LocationInputSerializer, LocationSerializer


class ShareLocationView(APIView):
    """Child posts their current location."""

    def post(self, request):
        if request.user.role != User.ROLE_CHILD:
            return Response({"detail": "children only"}, status=403)
        s = LocationInputSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        loc = LocationUpdate.objects.create(
            child=request.user,
            lat=s.validated_data["lat"],
            lng=s.validated_data["lng"],
            address=s.validated_data.get("address", ""),
            battery=s.validated_data.get("battery"),
            active=s.validated_data.get("active", True),
        )
        return Response(LocationSerializer(loc).data, status=201)


class ChildLatestLocationView(APIView):
    """Parent fetches latest location of a specific child."""

    def get(self, request, child_id):
        child = get_object_or_404(User, id=child_id, role=User.ROLE_CHILD)
        if request.user.role == User.ROLE_PARENT and child.parent_id != request.user.id:
            return Response({"detail": "forbidden"}, status=403)
        if request.user.role == User.ROLE_CHILD and request.user.id != child.id:
            return Response({"detail": "forbidden"}, status=403)
        loc = child.locations.first()
        if not loc:
            return Response({"detail": "no location yet"}, status=404)
        return Response(LocationSerializer(loc).data)


class ChildLocationHistoryView(APIView):
    def get(self, request, child_id):
        child = get_object_or_404(User, id=child_id, role=User.ROLE_CHILD)
        if request.user.role == User.ROLE_PARENT and child.parent_id != request.user.id:
            return Response({"detail": "forbidden"}, status=403)
        if request.user.role == User.ROLE_CHILD and request.user.id != child.id:
            return Response({"detail": "forbidden"}, status=403)
        qs = child.locations.all()[:100]
        return Response(LocationSerializer(qs, many=True).data)
