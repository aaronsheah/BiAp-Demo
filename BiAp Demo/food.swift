import UIKit

/***************************
            Meal Class
 
Description : holds the various Food Class instances

Example : Pizza of type Meal holds Large Pizza, Medium Pizza, and Small Pizza of type Food

Usage : init function = Meal(name:String, thumbnail:String, foods:NSArray)

***************************/

class Meal {
    
    var name:String = "name-not-assigned"
    var thumbnail:UIImage = UIImage()
    var foods:NSArray!
    
    init(name:String, thumbnail:String, foods:NSArray) {
        self.name = name
        self.thumbnail = UIImage(named: thumbnail)!
        self.foods = foods
    }
}

/***************************
            Food Class
 
Description : contains the information about the food

Info :
    name
    description
    id
    thumbnail
    glucoseProfile
    Carbohydrates
    Protein
    Fat

Usage : init function = Food(name:String, description:String, id:Int, thumbnail:String, glucoseProfile:NSMutableArray, cho:Float, protein:Float, fat:Float)

***************************/

class Food {
    var name:String = "name-not-assigned"
    var description:String = "desc-not-assigned"
    var id:Int = -1
    var thumbnail:UIImage = UIImage()
    
    var glucoseProfile:NSMutableArray = [-1]
    var glucoseTime:NSMutableArray = [-1]
    var cho:Float = -1
    var protein:Float = -1
    var fat:Float = -1

    init(name:String, description:String, id:Int, thumbnail:String, glucoseProfile:NSMutableArray, cho:Float, protein:Float, fat:Float) {
        self.name = name
        self.description = description
        self.id = id
        self.thumbnail = UIImage(named: thumbnail)!
        self.glucoseProfile = glucoseProfile
        self.cho = cho
        self.protein = protein
        self.fat = fat
        
        self.glucoseTime = []
        var counter = 0
        for x in glucoseProfile {
            counter = counter + 1
            glucoseTime.addObject(counter * 5)
        }
    }
}

/***************************
              16 Meals
***************************/

let bacon_and_eggs = Meal(
    name: "Bacon & Eggs",
    thumbnail: "bacon-and-eggs.jpg",
    foods: [
        Food(
            name: "Bacon & Eggs",
            description: "Scrambled eggs, Canadian bacon and gelatin (Jell-O)",
            id: 1,
            thumbnail: "bacon-and-eggs.jpg",
            glucoseProfile:[
                0,31.798,177.49,371.74,538.26,629.55,655.52,647.28,624.07,595.15,564.79,534.9,506.27,479.15,453.54,429.35,406.47,384.78,364.18,344.59,325.95,308.2,291.3,275.22,259.93,245.38,231.57,218.46,206.02,194.24,183.08,172.51,162.52,153.08,144.15,135.73,127.78,120.28,113.2,106.53,100.25,94.324,88.745,83.49,78.542,73.884,69.498,65.371,61.487,57.832,54.393,51.16,48.12,45.266,42.592,40.094,37.775,35.645,33.723,32.043
            ],
            cho: 45,
            protein: 15,
            fat: 40
        )
    ]
)

let cheese_sandwich = Meal(
    name: "Cheese Sandiwch",
    thumbnail: "cheese-sandwich.jpg",
    foods: [
        Food(
            name: "Cheese Sandiwch",
            description: "White bread, low-fat cheese, sucrose, oil, butter",
            id: 2,
            thumbnail: "cheese-sandwich.jpg",
            glucoseProfile: [
                0,40.539,126.33,159.3,208.92,251.96,287.66,316.87,340.37,358.88,373.02,383.39,390.53,394.92,397.03,397.27,396.03,393.67,390.49,386.73,382.57,378.07,373.2,367.81,361.66,354.5,346.13,336.43,325.45,313.33,300.3,286.66,272.67,258.58,244.59,230.85,217.49,204.58,192.19,180.35,169.06,158.35,148.21,138.62,129.57,121.05,113.02,105.48,98.406,91.764,85.538,79.706,74.246,69.138,64.362,59.898,55.728,51.835,48.202,44.812
            ],
            cho: 55,
            protein: 15,
            fat: 30
        )
    ]
)

let full_breakfast = Meal(
    name: "Full Breakfast", 
    thumbnail: "cereal.jpg", 
    foods: [
        Food(
            name: "Full Breakfast", 
            description: "Fat milk, white rice, low-fat cheese, fructose, pear, bran-cookies, oil", 
            id: 3, 
            thumbnail: "cereal.jpg", 
            glucoseProfile: [
                0,8.6444,50.968,112.8,164.56,193.2,216.98,241.76,266.43,289.45,309.86,327.2,341.32,352.29,360.28,365.53,368.31,368.89,367.55,364.54,360.1,354.44,347.78,340.27,332.09,323.37,314.23,304.79,295.15,285.39,275.6,265.86,256.23,246.8,237.65,228.86,220.53,212.77,205.68,199.38,193.97,189.49,185.93,183.14,180.8,178.49,175.7,171.98,167.07,160.91,153.65,145.52,136.83,127.84,118.81,109.93,101.35,93.154,85.414,78.163
            ],
            cho: 55,
            protein: 15,
            fat: 30
        )
    ]
)

let pasta_low = Food(
    name: "Low Fat", 
    description: "Pasta, Oil (Low Fat)", 
    id: 4, 
    thumbnail: "pasta.jpg", 
    glucoseProfile: [
        0,4.5652,27.657,64.2,106.9,150.99,193.4,232.15,265.92,293.69,314.63,328.16,334.39,334.43,330.18,323.62,316.35,309.34,303.05,297.61,292.92,288.84,285.17,281.78,278.54,275.4,272.32,269.3,266.36,263.54,260.87,258.39,256.09,253.93,251.86,249.75,247.44,244.77,241.55,237.66,232.99,227.52,221.28,214.34,206.81,198.82,190.51,182.01,173.43,164.87,156.42,148.14,140.09,132.3,124.8,117.61,110.74,104.2,97.976,92.073,86.483,81.196,76.202,71.489,67.046,62.861,58.921,55.215,51.73,48.454,45.377,42.487,39.775,37.229,34.841,32.601,30.501,28.532,26.686,24.957,23.337,21.819,20.398,19.068,17.822,16.656,15.564,14.543,13.587,12.693
    ],
    cho: 80,
    protein: 15.4,
    fat: 4.6
)

let pasta_medium = Food(
    name: "Medium Fat", 
    description: "Pasta, Oil (Medium Fat)", 
    id: 5, 
    thumbnail: "pasta.jpg", 
    glucoseProfile: [
        0,5.2125,30.548,67.213,106.88,145.43,180.92,212.45,239.64,262.22,279.85,292.03,298.2,298.05,292.01,281.43,268.34,254.82,242.5,232.38,224.91,220.14,217.88,217.81,219.56,222.73,226.93,231.77,236.89,241.95,246.64,250.68,253.87,256.03,257.06,256.92,255.62,253.21,249.77,245.42,240.28,234.48,228.14,221.4,214.35,207.09,199.71,192.28,184.86,177.49,170.23,163.11,156.14,149.35,142.75,136.35,130.17,124.2,118.44,112.9,107.58,102.47,97.562,92.863,88.363,84.058,79.94,76.005,72.246,68.658,65.233,61.967,58.853,55.885,53.057,50.363,47.799,45.357,43.034,40.824,38.722,36.723,34.822,33.016,31.299,29.668,28.119,26.647,25.25,23.923
    ],
    cho: 56,
    protein: 10.8,
    fat: 33.2
)

let pasta_high = Food(
    name: "High Fat", 
    description: "Pasta, Oil (High Fat)", 
    id: 6, 
    thumbnail: "pasta.jpg", 
    glucoseProfile: [
        0,5.8762,30.12,69.473,115.5,161.83,203.97,239.12,265.93,284.22,294.58,298.11,296.08,289.76,280.32,268.76,255.9,242.37,228.68,215.19,202.16,189.78,178.16,167.39,157.49,148.47,140.34,133.08,126.65,121.04,116.22,112.15,108.83,106.22,104.33,103.15,102.67,102.92,103.93,105.72,108.34,111.85,116.32,121.83,128.45,136.26,145.33,155.66,167.22,179.89,193.39,207.34,221.2,234.34,246.09,255.84,263.09,267.55,269.11,267.83,263.95,257.76,249.63,239.94,229.06,217.34,205.09,192.57,180.01,167.59,155.46,143.73,132.48,121.79,111.67,102.17,93.275,84.992,77.309,70.205,63.659,57.642,52.127,47.083,42.479,38.286,34.474,31.013,27.876,25.037
    ],
    cho: 37.4,
    protein: 7.2,
    fat: 55.4
)

let pasta = Meal(
    name: "Pasta", 
    thumbnail: "pasta.jpg", 
    foods: [
        pasta_low,
        pasta_medium,
        pasta_high
    ]
)

let rice_pudding = Meal(
    name: "Rice Pudding", 
    thumbnail: "rice-pudding.jpg", 
    foods: [

        Food(
            name: "Rice Pudding", 
            description: "Rice, pudding, sugar and cinnamon", 
            id: 7, 
            thumbnail: "rice-pudding.jpg", 
            glucoseProfile: [
                0,4.3776,27.04,63.673,107.08,151.75,193.14,227.53,252.85,269.22,278.26,281.95,281.96,279.52,275.5,270.5,264.94,259.15,253.36,247.77,242.53,237.8,233.71,230.4,228.03,226.71,226.57,227.67,229.99,233.39,237.55,242.05,246.38,250.07,252.72,254.09,254.07,252.67,249.98,246.13,241.28,235.62,229.29,222.46,215.25,207.79,200.18,192.5,184.82,177.21,169.7,162.34,155.16,148.17,141.4,134.85,128.54,122.46,116.62,111.02,105.65,100.51,95.598,90.906,86.426,82.153,78.08,74.198,70.501,66.981,63.631,60.443,57.412,54.528,51.787,49.181,46.704,44.35,42.114,39.989,37.97,36.052,34.231,32.501,30.858,29.297,27.815,26.408,25.072,23.803
            ],
            cho: 74.6,
            protein: 14.2,
            fat: 11.2
        )
    ]
)

let french_toast = Meal(
    name: "French Toast", 
    thumbnail: "french-toast.jpg", 
    foods: [
        Food(
            name: "French Toast", 
            description: "Toast, honey, ham, curd cheese, orange joice", 
            id: 8, 
            thumbnail: "french-toast.jpg", 
            glucoseProfile: [
                0,3.7563,23.664,57.199,98.88,144.43,190.46,234.13,272.94,304.86,328.93,345.66,356.52,363.14,366.8,368.41,368.49,367.38,365.25,362.22,358.37,353.75,348.44,342.49,335.98,329.02,321.7,314.13,306.46,298.83,291.38,284.26,277.57,271.35,265.56,260.01,254.46,248.61,242.22,235.15,227.35,218.87,209.82,200.33,190.54,180.6,170.62,160.71,150.96,141.45,132.24,123.36,114.86,106.75,99.056,91.773,84.905,78.448,72.393,66.729
            ],
            cho: 26.2,
            protein: 16.5,
            fat: 56.7
        )
    ]
)

let barley = Meal(
    name: "Barley", 
    thumbnail: "barley.jpg", 
    foods: [
        Food(
            name: "Barley", 
            description: "Pear barley", 
            id: 9, 
            thumbnail: "barley.jpg", 
            glucoseProfile: [
                0,14.801,87.131,194.95,308.25,400.41,450.91,463.61,455.99,440.75,424.17,408.83,395.45,383.92,373.84,364.73,356.2,347.92,339.68,331.35,322.88,314.28,305.6,296.92,288.39,280.17,272.47,265.56,259.74,255.42,253.06,253.18,256.22,262.29,270.59,279.04,284.68,285.14,279.58,268.57,253.38,235.44,216.01,196.1,176.47,157.64,139.95,123.58,108.63,95.116,83,72.212,62.664,54.254,46.877,40.432,34.817,29.939,25.712,22.057
            ],
            cho: 79,
            protein: 15,
            fat: 5
        )
    ]
)

let mashed_potato = Meal(
    name: "Mashed Potato", 
    thumbnail: "mashed-potato.jpg", 
    foods: [
        Food(
            name: "Mashed Potato", 
            description: "Instant Mashed Potato", 
            id: 10,
            thumbnail: "mashed-potato.jpg", 
            glucoseProfile: [
                0,145.84,380.7,526.72,658.59,757.96,820.77,850.61,853.61,836.12,803.85,761.53,712.94,661.02,608,555.74,506.26,463.1,434.22,419.64,389.91,346.57,300.22,256.36,217.11,183.01,153.84,129.12,108.26,90.725,76.005,63.661,53.316,44.649,37.389,31.309,26.218,21.954,18.383,15.394,12.89,10.794,9.0382,7.5682,6.3373,5.3066,4.4436,3.7209,3.1157,2.609
            ],
            cho: 78,
            protein: 22.3,
            fat: 28.7
        )
    ]
)

let eggs_and_toast = Meal(
    name: "Eggs & Toast", 
    thumbnail: "eggs-and-toast.jpg", 
    foods: [
        Food(
            name: "Eggs & Toast", 
            description: "2 slices of bread, 1 and ½ eggs, 1 tea spoon of margarine and orange juice", 
            id: 11,
            thumbnail: "eggs-and-toast.jpg", 
            glucoseProfile: [
                0,68.959,250.29,333.57,412.14,485.86,547.44,593.82,624.81,641.66,646.29,640.82,627.33,607.67,583.49,556.16,526.83,496.45,465.83,435.74,407.03,380.88,359.17,345.22,343.65,349.93,345.25,324.8,294.71,260.84,226.9,194.98,166.07,140.53,118.35,99.307,83.103,69.398,57.863,48.186,40.091,33.332,27.698,23.006,19.103,15.858,13.162,10.923,9.0632,7.5197,6.2386,5.1755,4.2934,3.5615,2.9543,2.4506,2.0327,1.6861,1.3985,1.16
            ],
            cho: 49,
            protein: 22.3,
            fat: 28.7
        )
    ]
)

let whipped_cream_cereal = Meal(
    name: "Whipped Cream Cereal", 
    thumbnail: "whipped-cream-cereal.jpg", 
    foods: [
        Food(
            name: "Whipped Cream Cereal", 
            description: "Cereal, coconut, chocolate, fruit and whipping cream", 
            id: 12,
             thumbnail: "whipped-cream-cereal.jpg", 
            glucoseProfile: [
                0,53.619,171.49,267.63,342,394.23,419.36,412.45,386.3,364.4,354.61,353.11,355.06,357.45,358.9,358.93,357.51,354.82,351.12,346.72,341.91,337,332.29,328.03,324.43,321.6,319.48,317.79,316.02,313.43,309.23,302.8,293.86,282.53,269.27,254.68,239.35,223.82,208.46,193.55,179.28,165.76,153.02,141.09,129.97,119.63,110.04,101.16,92.952,85.373,78.382,71.94,66.007,60.546,55.523,50.904,46.659,42.759,39.178,35.889,32.871,30.102,27.561,25.231,23.095,21.136,19.341,17.696,16.188,14.808,13.543,12.385,11.325,10.354,9.4651,8.6519,7.9077,7.2268,6.6038,6.034
            ],
            cho: 18,
            protein: 16,
            fat: 66
        )
    ]
)

let oats1 = Food(
    name: "1", 
    description: "Oats, coconut, almonds, raisins, honey, sunflower oil, banana, double cream and milk", 
    id: 13,
    thumbnail: "oats.jpeg",
    glucoseProfile: [
        0,9.7188,56.469,125.26,199.42,269.22,328.34,371.61,396.13,405.36,406.94,406.59,406.49,406.78,406.9,406.33,404.78,402.16,398.56,394.19,389.27,384.05,378.69,373.24,367.58,361.46,354.53,346.42,336.85,325.73,313.15,299.31,284.55,269.2,253.6,238.02,222.71,207.83,193.52,179.86,166.9,154.67,143.17,132.4,122.34,112.96,104.23,96.117,88.59,81.613,75.154,69.177,63.652,58.548,53.835,49.486,45.475,41.778,38.371,35.232
    ],
    cho: 48.6,
    protein: 6.9,
    fat: 48
)

let oats2 = Food(
    name: "2", 
    description: "Oats, coconut, almonds, raisins, honey, sunflower oil, banana, double cream and milk", 
    id: 14,
     thumbnail: "oats.jpeg", 
    glucoseProfile: [
        0,58.984,108.68,150.19,198.46,238.81,272.12,299.26,320.99,337.98,350.84,360.12,366.31,369.82,371.07,370.41,368.17,364.65,360.15,354.95,349.34,343.6,338.01,332.88,328.49,325.12,323.02,322.3,322.95,324.63,326.65,327.93,327.16,323.16,315.3,303.66,288.94,272.11,254.15,235.87,217.86,200.5,184.02,168.56,154.16,140.82,128.51,117.2,106.81,97.297,88.594,80.641,73.38,66.755,60.714,55.208,50.192,45.624,41.465,37.68
    ],
    cho: 28.2,
    protein: 6.6,
    fat: 65.2
)

let oats3 = Food(
    name: "3", 
    description: "Oats, coconut, almonds, raisins, honey, sunflower oil, banana, double cream and milk", 
    id: 15,
     thumbnail: "oats.jpeg", 
    glucoseProfile: [
        0,14.241,48.502,95.83,145.53,191.87,232.74,267.66,296.85,320.79,340.08,355.3,367.05,375.89,382.34,386.91,390.08,392.28,393.92,395.32,396.71,398.17,399.59,400.61,400.71,399.18,395.38,388.84,379.37,367.15,352.59,336.25,318.72,300.58,282.27,264.17,246.54,229.57,213.37,198.02,183.54,169.95,157.22,145.34,134.26,123.96,114.39,105.51,97.282,89.659,82.605,76.08,70.05,64.479,59.335,54.588,50.208,46.169,42.446,39.014
    ],
    cho: 20,
    protein: 6.1,
    fat: 73.9
)

let oats = Meal(
    name: "Oats",
    thumbnail: "oats.jpeg",
    foods: [
        oats1,
        oats2,
        oats3
    ]
)

let breakfast = Meal(
    name: "Breakfast", 
    thumbnail: "breakfast.jpg", 
    foods : [
        Food(
            name: "Breakfast", 
            description: "Oat loop cereal, milk, white bread, margarine, strawberry jam, orange juice", 
            id: 16,
            thumbnail: "breakfast.jpg", 
            glucoseProfile: [
                0,68.041,202.78,307.66,378.44,395.31,358.96,329.06,324.74,333.95,347.19,360.39,372.35,383.07,392.91,402.3,411.54,420.71,429.59,437.55,443.57,446.43,445,438.62,427.28,411.6,392.57,371.31,348.84,325.99,303.34,281.34,260.26,240.25,221.41,203.76,187.3,172.01,157.82,144.71,132.59,121.42,111.14,101.67,92.975,84.987,77.655,70.931,64.768,59.122,53.952,49.221,44.892,40.933,37.315,34.008,30.987,28.229,25.71,23.412
            ],
            cho: 57,
            protein: 19,
            fat: 24
        )
    ]
)

/***************************
            Meal Library
***************************/

let mealLibrary = [
    bacon_and_eggs,
    cheese_sandwich,
    full_breakfast,
    pasta,
    rice_pudding,
    french_toast,
    barley,
    mashed_potato,
    eggs_and_toast,
    whipped_cream_cereal,
    oats,
    breakfast
]
