import requests

with open(r"C:\Users\Ymiha\Downloads\010e_Wild_Bearded_Vulture_in_flight_at_Pfyn-Finges_(Switzerland)_Photo_by_Giles_Laurent.jpg","rb") as f:
    r = requests.post("http://localhost:8081/api/search_image", files={"file": f})
    print(r.status_code, r.text)
