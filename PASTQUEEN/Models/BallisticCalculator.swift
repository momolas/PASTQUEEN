//
//  BallisticCalculator.swift
//  DropZero-P3
//
//  Created by Richard Padgett on 10/12/16.
//  Copyright © 2016 Richard-Padgett. All rights reserved.
//

import Foundation
import CoreLocation

struct BallisticCalculator {
    
    // Constants
    let GRAVITY = -32.194
    let _BCOMP_MAXRANGE_ = 5001
    
    // Weather data structure
    struct WeatherData {
        var windSpeed: Double = 0.0
        var windDirection: Double = 0.0
        var pressure: Double = 29.53
        var temperatureF: Double = 59.0
        var humidity: Double = 0.78
        var altitude: Double = 0.0
    }
    
    // Input parameters from the Ballistics model
    private let ballistics: Ballistics
    
    // Weather and environmental conditions
    private let weather: WeatherData
    
    init(ballistics: Ballistics, weather: WeatherData) {
        self.ballistics = ballistics
        self.weather = weather
    }
    
    // MARK: - Public Calculation Functions

    public func solveTrajectory(for distance: Double) -> [Double] {
        let bc = correctedBallisticCoefficient()
        let zeroAngle = calculateZeroAngle()
        
        let results = solveAll(
            dragFunction: Int(ballistics.dragFunction),
            dragCoefficient: bc,
            vi: ballistics.muzzleVelocity,
            sightHeight: ballistics.sightHeight,
            projectileWeight: Int(ballistics.projectileWeight),
            shootingAngle: 0, // Assuming flat fire for now, can be extended
            zAngle: zeroAngle,
            windSpeed: weather.windSpeed,
            windAngle: weather.windDirection,
            start: Int(distance),
            stop: Int(distance)
        )

        return results
    }
    
    // MARK: - Core Ballistic Calculations

    private func correctedBallisticCoefficient() -> Double {
        return atmCorrect(
            dragCoefficient: ballistics.ballisticCoefficient,
            altitude: weather.altitude,
            barometer: weather.pressure,
            temperature: weather.temperatureF,
            relativeHumidity: weather.humidity
        )
    }
    
    private func calculateZeroAngle() -> Double {
        return zeroAngle(
            dragFunction: Int(ballistics.dragFunction),
            dragCoefficient: correctedBallisticCoefficient(),
            vi: ballistics.muzzleVelocity,
            sightHeight: ballistics.sightHeight,
            zeroRange: ballistics.zeroRange,
            yIntercept: 0
        )
    }

    // MARK: - Angle and Unit Conversions
    
    private func degToRad(_ deg: Double) -> Double {
        return deg * .pi / 180
    }
    
    private func radToDeg(_ rad: Double) -> Double {
        return rad * 180 / .pi
    }
    
    private func radToMOA(_ rad: Double) -> Double {
        return rad * 60 * 180 / .pi
    }
    
    private func moaToRad(_ moa: Double) -> Double {
        return moa / 60 * .pi / 180
    }

    // MARK: - Atmospheric Corrections
    
    private func atmCorrect(dragCoefficient: Double, altitude: Double, barometer: Double, temperature: Double, relativeHumidity: Double) -> Double {
        let fa = calcFA(altitude: altitude)
        let ft = calcFT(temperature: temperature, altitude: altitude)
        let fr = calcFR(temperature: temperature, pressure: barometer, relativeHumidity: relativeHumidity)
        let fp = calcFP(pressure: barometer)

        let cd = (fa * (1 + ft - fp) * fr)
        return dragCoefficient * cd
    }
    
    private func calcFA(altitude: Double) -> Double {
        let fa = -4e-15 * pow(altitude, 3) + 4e-10 * pow(altitude, 2) - 3e-5 * altitude + 1
        return (1 / fa)
    }
    
    private func calcFT(temperature: Double, altitude: Double) -> Double {
        let tstd = -0.0036 * altitude + 59
        let ft = (temperature - tstd) / (459.6 + tstd)
        return ft
    }
    
    private func calcFP(pressure: Double) -> Double {
        let pstd = 29.53 //in-hg
        let fp = (pressure - pstd) / (pstd)
        return fp
    }
    
    private func calcFR(temperature: Double, pressure: Double, relativeHumidity: Double) -> Double {
        let vpw = 4e-6 * pow(temperature, 3) - 0.0004 * pow(temperature, 2) + 0.0234 * temperature - 0.2517
        let frh = 0.995 * (pressure / (pressure - (0.3783) * (relativeHumidity) * vpw))
        return frh
    }

    // MARK: - Drag and Retardation
    
    private func retard(dragFunction: Int, dragCoefficient: Double, velocity: Double) -> Double {
        let vp: Double = velocity
        var val: Double = -1
        var a: Double = -1
        var m: Double = -1
        
        // This large switch statement is a direct port of the original logic.
        // It could be refactored into a more data-driven structure in the future.
        switch(dragFunction) {
        case 1: // G1 Drag Function
            if (vp > 4230) { a = 1.477404177730177e-04; m = 1.9565; }
            else if (vp > 3680) { a = 1.920339268755614e-04; m = 1.925 ; }
            else if (vp > 3450) { a = 2.894751026819746e-04; m = 1.875 ; }
            else if (vp > 3295) { a = 4.349905111115636e-04; m = 1.825 ; }
            else if (vp > 3130) { a = 6.520421871892662e-04; m = 1.775 ; }
            else if (vp > 2960) { a = 9.748073694078696e-04; m = 1.725 ; }
            else if (vp > 2830) { a = 1.453721560187286e-03; m = 1.675 ; }
            else if (vp > 2680) { a = 2.162887202930376e-03; m = 1.625 ; }
            else if (vp > 2460) { a = 3.209559783129881e-03; m = 1.575 ; }
            else if (vp > 2225) { a = 3.904368218691249e-03; m = 1.55  ; }
            else if (vp > 2015) { a = 3.222942271262336e-03; m = 1.575 ; }
            else if (vp > 1890) { a = 2.203329542297809e-03; m = 1.625 ; }
            else if (vp > 1810) { a = 1.511001028891904e-03; m = 1.675 ; }
            else if (vp > 1730) { a = 8.609957592468259e-04; m = 1.75  ; }
            else if (vp > 1595) { a = 4.086146797305117e-04; m = 1.85  ; }
            else if (vp > 1520) { a = 1.954473210037398e-04; m = 1.95  ; }
            else if (vp > 1420) { a = 5.431896266462351e-05; m = 2.125 ; }
            else if (vp > 1360) { a = 8.847742581674416e-06; m = 2.375 ; }
            else if (vp > 1315) { a = 1.456922328720298e-06; m = 2.625 ; }
            else if (vp > 1280) { a = 2.419485191895565e-07; m = 2.875 ; }
            else if (vp > 1220) { a = 1.657956321067612e-08; m = 3.25  ; }
            else if (vp > 1185) { a = 4.745469537157371e-10; m = 3.75  ; }
            else if (vp > 1150) { a = 1.379746590025088e-11; m = 4.25  ; }
            else if (vp > 1100) { a = 4.070157961147882e-13; m = 4.75  ; }
            else if (vp > 1060) { a = 2.938236954847331e-14; m = 5.125 ; }
            else if (vp > 1025) { a = 1.228597370774746e-14; m = 5.25  ; }
            else if (vp >  980) { a = 2.916938264100495e-14; m = 5.125 ; }
            else if (vp >  945) { a = 3.855099424807451e-13; m = 4.75  ; }
            else if (vp >  905) { a = 1.185097045689854e-11; m = 4.25  ; }
            else if (vp >  860) { a = 3.566129470974951e-10; m = 3.75  ; }
            else if (vp >  810) { a = 1.045513263966272e-08; m = 3.25  ; }
            else if (vp >  780) { a = 1.291159200846216e-07; m = 2.875 ; }
            else if (vp >  750) { a = 6.824429329105383e-07; m = 2.625 ; }
            else if (vp >  700) { a = 3.569169672385163e-06; m = 2.375 ; }
            else if (vp >  640) { a = 1.839015095899579e-05; m = 2.125 ; }
            else if (vp >  600) { a = 5.71117468873424e-05 ; m = 1.950 ; }
            else if (vp >  550) { a = 9.226557091973427e-05; m = 1.875 ; }
            else if (vp >  250) { a = 9.337991957131389e-05; m = 1.875 ; }
            else if (vp >  100) { a = 7.225247327590413e-05; m = 1.925 ; }
            else if (vp >   65) { a = 5.792684957074546e-05; m = 1.975 ; }
            else if (vp >    0) { a = 5.206214107320588e-05; m = 2.000 ; }
            break;
            
        case 2: // G2
            if (vp > 1674 ) { a = 0.0079470052136733   ;  m = 1.36999902851493; }
            else if (vp > 1172 ) { a = 1.00419763721974e-03;  m = 1.65392237010294; }
            else if (vp > 1060 ) { a = 7.15571228255369e-23;  m = 7.91913562392361; }
            else if (vp >  949 ) { a = 1.39589807205091e-10;  m = 3.81439537623717; }
            else if (vp >  670 ) { a = 2.34364342818625e-04;  m = 1.71869536324748; }
            else if (vp >  335 ) { a = 1.77962438921838e-04;  m = 1.76877550388679; }
            else if (vp >    0 ) { a = 5.18033561289704e-05;  m = 1.98160270524632; }
            break
            
        case 5: // G5
            if (vp > 1730 ){ a = 7.24854775171929e-03; m = 1.41538574492812; }
            else if (vp > 1228 ){ a = 3.50563361516117e-05; m = 2.13077307854948; }
            else if (vp > 1116 ){ a = 1.84029481181151e-13; m = 4.81927320350395; }
            else if (vp > 1004 ){ a = 1.34713064017409e-22; m = 7.8100555281422 ; }
            else if (vp >  837 ){ a = 1.03965974081168e-07; m = 2.84204791809926; }
            else if (vp >  335 ){ a = 1.09301593869823e-04; m = 1.81096361579504; }
            else if (vp >    0 ){ a = 3.51963178524273e-05; m = 2.00477856801111; }
            break;
            
        case 6: // G6
            if (vp > 3236 ) { a = 0.0455384883480781   ; m = 1.15997674041274; }
            else if (vp > 2065 ) { a = 7.167261849653769e-02; m = 1.10704436538885; }
            else if (vp > 1311 ) { a = 1.66676386084348e-03 ; m = 1.60085100195952; }
            else if (vp > 1144 ) { a = 1.01482730119215e-07 ; m = 2.9569674731838 ; }
            else if (vp > 1004 ) { a = 4.31542773103552e-18 ; m = 6.34106317069757; }
            else if (vp >  670 ) { a = 2.04835650496866e-05 ; m = 2.11688446325998; }
            else if (vp >    0 ) { a = 7.50912466084823e-05 ; m = 1.92031057847052; }
            break;
            
        case 7: // G7
            if (vp > 4200 ) { a = 1.29081656775919e-09; m = 3.24121295355962; }
            else if (vp > 3000 ) { a = 0.0171422231434847  ; m = 1.27907168025204; }
            else if (vp > 1470 ) { a = 2.33355948302505e-03; m = 1.52693913274526; }
            else if (vp > 1260 ) { a = 7.97592111627665e-04; m = 1.67688974440324; }
            else if (vp > 1110 ) { a = 5.71086414289273e-12; m = 4.3212826264889 ; }
            else if (vp >  960 ) { a = 3.02865108244904e-17; m = 5.99074203776707; }
            else if (vp >  670 ) { a = 7.52285155782535e-06; m = 2.1738019851075 ; }
            else if (vp >  540 ) { a = 1.31766281225189e-05; m = 2.08774690257991; }
            else if (vp >    0 ) { a = 1.34504843776525e-05; m = 2.08702306738884; }
            break;
            
        case 8: // G8
            if (vp > 3571 ) { a = 0.0112263766252305   ; m = 1.33207346655961; }
            else if (vp > 1841 ) { a = 0.0167252613732636   ; m = 1.28662041261785; }
            else if (vp > 1120 ) { a = 2.20172456619625e-03; m = 1.55636358091189; }
            else if (vp > 1088 ) { a = 2.0538037167098e-16 ; m = 5.80410776994789; }
            else if (vp >  976 ) { a = 5.92182174254121e-12; m = 4.29275576134191; }
            else if (vp >    0 ) { a = 4.3917343795117e-05 ; m = 1.99978116283334; }
            break;
            
        default:
            break;
        }
        
        if (a != -1 && m != -1 && vp > 0 && vp < 10000) {
            val = a * pow(vp, m) / dragCoefficient
            return val
        } else {
            return -1
        }
    }

    // MARK: - Windage Calculations
    
    private func windage(windSpeed: Double, vi: Double, xx: Double, t: Double) -> Double {
        let vw = windSpeed * 17.60 //Convert to inches per second
        return (vw * (t - xx / vi))
    }
    
    private func headWind(windSpeed: Double, windAngle: Double) -> Double {
        let wangle = degToRad(windAngle)
        return (cos(wangle) * windSpeed)
    }
    
    private func crossWind(windSpeed: Double, windAngle: Double) -> Double {
        let wangle = degToRad(windAngle)
        return (sin(wangle) * windSpeed)
    }

    // MARK: - Zero Angle Calculation
    
    private func zeroAngle(dragFunction: Int, dragCoefficient: Double, vi: Double, sightHeight: Double, zeroRange: Double, yIntercept: Double) -> Double {
        var t: Double = 0
        var dt = 1 / vi
        var y = -(sightHeight / 12)
        var x: Double = 0
        var da: Double
        
        var v: Double = 0
        var vx: Double = 0
        var vy: Double = 0
        
        var vx1: Double = 0
        var vy1: Double = 0
        
        var dv: Double = 0
        var dvx: Double = 0
        var dvy: Double = 0
        
        var gx: Double = 0
        var gy: Double = 0
        
        var angle: Double = 0
        var quit: Int = 0
        
        da = degToRad(14)
        
        while(quit == 0) {
            angle = angle + da
            
            vy = vi * sin(angle)
            vx = vi * cos(angle)
            gx = GRAVITY * sin(angle)
            gy = GRAVITY * cos(angle)
            
            t = 0
            x = 0
            y = -(sightHeight / 12)
            
            while(x < zeroRange * 3) {
                t = t + dt
                
                vy1 = vy
                vx1 = vx
                v = pow((pow(vx, 2) + pow(vy, 2)), 0.5)
                dt = 1 / v
                
                dv = retard(dragFunction: dragFunction, dragCoefficient: dragCoefficient, velocity: v)
                dvy = -(dv * vy / v * dt)
                dvx = -(dv * vx / v * dt)
                
                vx = vx + dvx
                vy = vy + dvy
                vy = vy + dt * gy
                vx = vx + dt * gx
                
                x = x + dt * (vx + vx1) / 2
                y = y + dt * (vy + vy1) / 2
                
                if (vy < 0 && y < yIntercept) { break }
                if (vy > 3 * vx) { break }
            }
            
            if (y > yIntercept && da > 0) { da = -(da / 2) }
            if (y < yIntercept && da < 0) { da = -(da / 2) }
            if (abs(da) < moaToRad(0.01)) { quit = 1 }
            if (angle > degToRad(45)) { quit = 1 }
        }
        return radToDeg(angle)
    }

    // MARK: - Trajectory Solver

    private func solveAll(dragFunction: Int, dragCoefficient: Double, vi: Double, sightHeight: Double, projectileWeight: Int, shootingAngle: Double, zAngle: Double, windSpeed: Double, windAngle: Double, start: Int, stop: Int) -> [Double] {
        var retArray: [Double] = []
        var t: Double = 0
        var dt: Double = 0.5 / vi
        var v: Double = 0
        var vx: Double = 0
        var vx1: Double = 0
        var vy: Double = 0
        var vy1: Double = 0
        var dv: Double = 0
        var dvx: Double = 0
        var dvy: Double = 0
        var x: Double = 0
        var y: Double = 0
        
        let headwind = headWind(windSpeed: windSpeed, windAngle: windAngle)
        let crosswind = crossWind(windSpeed: windSpeed, windAngle: windAngle)
        
        let gy = GRAVITY * (cos(degToRad(shootingAngle + zAngle)))
        let gx = GRAVITY * (sin(degToRad(shootingAngle + zAngle)))
        
        vx = vi * cos(degToRad(zAngle))
        vy = vi * sin(degToRad(zAngle))
        
        y = -(sightHeight / 12)
        
        var n: Int = start
        t = 0
        while(true) {
            t = t + dt
            vx1 = vx
            vy1 = vy
            v = pow(pow(vx, 2) + pow(vy, 2), 0.5)
            dt = 0.5 / v
            
            dv = retard(dragFunction: dragFunction, dragCoefficient: dragCoefficient, velocity: v + headwind)
            dvx = -(vx / v) * dv
            dvy = -(vy / v) * dv
            
            vx = vx + dt * dvx + dt * gx
            vy = vy + dt * dvy + dt * gy
            
            if (Int(x / 3) >= n) {
                retArray.append(x / 3) // Range (yards)
                retArray.append(y * 12) // Path (inches)
                retArray.append(-radToMOA(atan(y / x))) // MOA
                retArray.append(t + dt) // Time (seconds)
                retArray.append(windage(windSpeed: crosswind, vi: vi, xx: x, t: t + dt)) // Windage (inches)
                retArray.append(radToMOA(atan(((windage(windSpeed: crosswind, vi: vi, xx: x, t: t + dt)) / 12) / ((x / 3) * 3)))) // Windage (MOA)
                retArray.append(v) // Velocity (ft/s)
                
                let energy = (Double(projectileWeight) * v * v) / 450436
                retArray.append(energy) // Energy (ft-lbs)
                
                n = n + 1
                if (start >= stop) {
                    break
                }
            }
            
            x = x + dt * (vx + vx1) / 2
            y = y + dt * (vy + vy1) / 2
            
            if (abs(vy) > abs(3 * vx)) { break }
            if (n >= _BCOMP_MAXRANGE_ + 1) { break }
        }
        
        if retArray.isEmpty {
            return Array(repeating: 0.0, count: 8)
        }
        
        return retArray
    }
}