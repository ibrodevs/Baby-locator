# Kid Security — Django REST backend

## Setup

```bash
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
python manage.py makemigrations accounts tracking
python manage.py migrate
python manage.py createsuperuser   # optional, for /admin/
python manage.py runserver 0.0.0.0:8000
```

## API

All requests use `Authorization: Token <key>` except register/login.

### Auth
- `POST /api/auth/register/` — parent sign-up. Body: `{username, password, display_name?}`. Returns `{token, user}`.
- `POST /api/auth/login/` — sign-in (parent or child). Body: `{username, password}`. Returns `{token, user}`.
- `GET  /api/auth/me/` — current user.

### Children (parent only)
- `GET  /api/auth/children/` — list my children.
- `POST /api/auth/children/` — create child account. Body: `{username, password, display_name?}`.

### Location
- `POST /api/locations/` — child shares location. Body: `{lat, lng, address?, battery?, active?}`.
- `GET  /api/children/<id>/location/` — latest location of a child (parent or that child).
- `GET  /api/children/<id>/history/` — last 100 points.

## Models
- `accounts.User` (custom): `role` ∈ {parent, child}, `parent` FK for children.
- `tracking.LocationUpdate`: child, lat, lng, address, battery, active, created_at.
