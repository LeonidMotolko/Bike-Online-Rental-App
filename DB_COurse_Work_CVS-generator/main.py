import csv
from faker import Faker
import random
from datetime import timedelta

fake = Faker()

# 1. Users
with open('users.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['user_id', 'full_name', 'email', 'phone', 'password', 'created_at'])
    for i in range(1, 11):  # 10 users
        writer.writerow([
            i,
            fake.name(),
            fake.email(),
            fake.phone_number(),
            fake.password(length=10),
            fake.date_time_this_year().isoformat()
        ])

# 2. Bike Categories
bike_categories = [
    (1, "Mountain Bike"),
    (2, "City Bike"),
    (3, "Electric Bike"),
    (4, "Road Bike")
]
with open('bike_categories.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['category_id', 'category_name'])
    writer.writerows(bike_categories)

# 3. Bikes
with open('bikes.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['bike_id', 'model', 'brand', 'category_id', 'price_per_hour', 'is_available'])
    for i in range(1, 21):  # 20 байков
        writer.writerow([
            i,
            fake.word().capitalize() + str(random.randint(100, 999)),
            fake.company(),
            random.randint(1, 4),
            round(random.uniform(3, 15), 2),
            random.choice([True, False])
        ])

# 4. Locations
locations = [
    (1, "123 Bike Lane", "Vilnius"),
    (2, "456 City Road", "Kaunas"),
    (3, "789 Forest Path", "Klaipėda")
]
with open('locations.csv', 'w', newline='', encoding= 'utf-8') as f:
    writer = csv.writer(f)
    writer.writerow(['location_id', 'address', 'city'])
    writer.writerows(locations)

# 5. Payment Methods
methods = [
    (1, "Visa"),
    (2, "MasterCard"),
    (3, "PayPal")
]
with open('payment_methods.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['method_id', 'method_name'])
    writer.writerows(methods)

# 6. Rentals
with open('rentals.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['rental_id', 'user_id', 'bike_id', 'location_id', 'start_time', 'end_time', 'total_cost'])
    for i in range(1, 21):
        start = fake.date_time_this_year()
        end = start + timedelta(hours=random.randint(1, 5))
        cost = round(random.uniform(5, 50), 2)
        writer.writerow([
            i,
            random.randint(1, 10),     # user_id
            random.randint(1, 20),     # bike_id
            random.randint(1, 3),      # location_id
            start.isoformat(),
            end.isoformat(),
            cost
        ])

# 7. Payments
with open('payments.csv', 'w', newline='') as f:
    writer = csv.writer(f)
    writer.writerow(['payment_id', 'rental_id', 'method_id', 'paid_at', 'amount'])
    for i in range(1, 21):
        writer.writerow([
            i,
            i,                              # one payment = one rent
            random.randint(1, 3),           # method_id
            fake.date_time_this_year().isoformat(),
            round(random.uniform(5, 50), 2) # sum
        ])
