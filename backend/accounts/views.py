from rest_framework import status
from rest_framework.permissions import AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView

from .models import User
from .serializers import (
    CreateChildSerializer,
    LoginSerializer,
    RegisterParentSerializer,
    UserSerializer,
    token_for,
)


class RegisterParentView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        s = RegisterParentSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        user = s.save()
        return Response(
            {"token": token_for(user), "user": UserSerializer(user).data},
            status=status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        s = LoginSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        user = s.validated_data["user"]
        return Response({"token": token_for(user), "user": UserSerializer(user).data})


class MeView(APIView):
    def get(self, request):
        return Response(UserSerializer(request.user).data)


class ChildrenView(APIView):
    def get(self, request):
        if request.user.role != User.ROLE_PARENT:
            return Response({"detail": "parents only"}, status=403)
        qs = request.user.children.all().order_by("id")
        return Response(UserSerializer(qs, many=True).data)

    def post(self, request):
        if request.user.role != User.ROLE_PARENT:
            return Response({"detail": "parents only"}, status=403)
        s = CreateChildSerializer(data=request.data)
        s.is_valid(raise_exception=True)
        child = User.objects.create_user(
            username=s.validated_data["username"],
            password=s.validated_data["password"],
            display_name=s.validated_data.get("display_name", ""),
            role=User.ROLE_CHILD,
            parent=request.user,
        )
        return Response(UserSerializer(child).data, status=201)
