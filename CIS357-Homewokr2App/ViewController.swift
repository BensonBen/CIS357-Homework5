/* ----------------------------------------------------------------------
 * Name: Ben Benson, Benjamin Commet
 * Date: 2/16/19
 * Program: View Controller
 * Description: Designed to handle inputs from the user on the main
 * screen, and handle data control from the settings screen
 * -------------------------------------------------------------------- */
import UIKit
import CoreLocation
class ViewController: UIViewController, SettingsViewControllerDelegate {

    @IBOutlet weak var latitudeP1: DecimalMinusTextField!
    @IBOutlet weak var longitudeP1: DecimalMinusTextField!
    @IBOutlet weak var latitudeP2: DecimalMinusTextField!
    @IBOutlet weak var longitudeP2: DecimalMinusTextField!
    
    @IBOutlet weak var distanceTextField: UILabel!
    
    @IBOutlet weak var bearingTextField: UILabel!
    
    @IBOutlet weak var calculateButton: UIButton!
    
    @IBOutlet weak var clearButton: UIButton!
    
    var coordinate0: CLLocation!;
    var coordinate1: CLLocation!;
    
    var distanceType: String?
    
    var bearingType: String?
    
    var isDegrees: Bool = true;
    
    var isKilometers: Bool = true;
    
    func changeUnits(distanceType distanceUnits: String, bearingType bearingUnits: String){
        if distanceType == "Kilometers"{
            isKilometers = true
        }
        else{
            isKilometers = false
        }
        if bearingType == "Degrees"{
            isDegrees = true
        }else{
            isDegrees = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destVC = segue.destination.childViewControllers[0] as? SettingsViewController{
            destVC.delegate = self
            self.bearingType = destVC.bearingType
            self.distanceType = destVC.distanceType
            changeUnits(distanceType: self.bearingType!, bearingType: self.distanceType!)
        }
        
    }
    
    @IBAction func calculateButtonPress(_ sender: UIButton) {
        
        self.coordinate0 = CLLocation(latitude: Double(latitudeP1.text!)!, longitude: Double( longitudeP1.text!)!);
        
        self.coordinate1 = CLLocation(latitude: Double(latitudeP2.text!)!, longitude: Double(longitudeP2.text!)!);
        
        calculateDistance();
        
        //getBearingBetweenTwoPoints();
        getBearing()
    }
    
    @IBAction func clearButtonPress(_ sender: UIButton) {
        self.latitudeP1.text = ""
        self.latitudeP2.text = ""
        self.longitudeP1.text = ""
        self.longitudeP2.text = ""
        self.bearingTextField.text = "Bearing: "
        self.distanceTextField.text = "Distance: "
    }
    
    func calculateDistance() {
        let distance = coordinate0.distance(from: coordinate1);
        var km = distance/1000;
        if !isKilometers {
            km = km * 0.621;
        }
        let multiplier = pow(10.0, 2.0)
        let rounded = round(km * multiplier) / multiplier
        
        if isKilometers{
            distanceTextField.text = "Distance: \(rounded) km";
        }
        else{
            distanceTextField.text = "Distance: \(rounded) miles";
        }
    }
    
    func convertRadsToDegrees(radians: Double) -> Double {
        return radians * 180.0 / M_PI
    }
    
    func getBearingBetweenTwoPoints(){
//Credit: http://stackoverflow.com/questions/26998029/calculating-bearing-between-two-cllocation-points-in-swift
        let x = self.coordinate0.coordinate.longitude - self.coordinate1.coordinate.longitude
        let y = self.coordinate0.coordinate.latitude - self.coordinate1.coordinate.latitude
        var angle: Double = fmod(convertRadsToDegrees(radians: atan2(y, x)), 360.0) + 90.0;
        
        angle = angle * 17.777777777778
        let multiplier = pow(10.0, 2.0)
        let rounded = round(angle * multiplier) / multiplier
        
    }
    
    func degreesToRadians(degrees: Double) -> Double { return degrees * M_PI / 180.0 }
    
    func getBearing(){
        let lat1 = degreesToRadians(degrees:self.coordinate0.coordinate.latitude)
        let lon1 = degreesToRadians(degrees:self.coordinate0.coordinate.longitude)

        let lat2 = degreesToRadians(degrees:self.coordinate1.coordinate.latitude)
        let lon2 = degreesToRadians(degrees:self.coordinate1.coordinate.longitude)
        
        let dLon = lon2 - lon1
        
        let y = sin(dLon * cos(lat2))
        let x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon)
        let radiansBearing = atan2(y, x)
        
        
        var bearing = convertRadsToDegrees(radians:radiansBearing)
        if !isDegrees{
            bearing = bearing * 17.777777777778
        }
        let multiplier = pow(10.0, 2.0)
        let rounded = round(bearing * multiplier) / multiplier
        
        if isDegrees{
            bearingTextField.text = "Bearing: "+String(rounded)+"°";
        }
        else{
            bearingTextField.text = "Bearing: "+String(rounded) + "mils.";
        }
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        //tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

