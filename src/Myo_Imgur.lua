scriptId = 'com.lloydtorres.imgur'

-- Lua script to enable browsing Imgur using the Myo.
-- A lot of the code was taken from the Myo SDK docs.

-- Variables

unlocked = false

fistMade = false -- Flags for holding fist
referenceRoll = myo.getRoll()
currentRoll = referenceRoll

-- Effects

function nextPicture()
	myo.keyboard("right_arrow","press")
end

function prevPicture()
	myo.keyboard("left_arrow","press")
end

function scrollUp()
	myo.keyboard("up_arrow","down")
end

function scrollDown()
	myo.keyboard("down_arrow","down")
end

function resizePicture()
	myo.keyboard("return","press")
end

function resetFist()
    fistMade = false
    referenceRoll = myo.getRoll()
    currentRoll = referenceRoll
    myo.keyboard("up_arrow","up")
    myo.keyboard("down_arrow","up")
end

-- Helpers

function conditionallySwapWave(pose) - Changes waveIn/waveOut to be waveLeft/waveRight instead
    if myo.getArm() == "left" then
        if pose == "waveIn" then
            pose = "waveOut"
        elseif pose == "waveOut" then
            pose = "waveIn"
        end
    end
    return pose
end

-- Callbacks

function onPoseEdge(pose, edge)


    pose = conditionallySwapWave(pose)

    if pose == "thumbToPinky" then
        if not unlocked then -- Unlock
            if edge == "off" then
                unlocked = true
            elseif edge == "on" and not unlocked then
                myo.vibrate("medium")
            end
        elseif unlocked then -- Lock
            if edge == "off" then
                unlocked = false
            elseif edge == "on" and not unlocked then
                myo.vibrate("medium")
            end
        end
    end

    -- Other gestures
    if unlocked and edge == "on" then

        pose = conditionallySwapWave(pose)

        if pose == "waveOut" then
            myo.vibrate("short")
            nextPicture()
        elseif pose == "waveIn" then
            myo.vibrate("short")
            prevPicture()
        elseif pose == "fingersSpread" then
            resizePicture()
        elseif pose == "fist" and not fistMade then -- Sets up fist movement
            referenceRoll = myo.getRoll()
            fistMade = true
            if myo.getXDirection() == "towardElbow" then -- Adjusts for Myo orientation
                referenceRoll = referenceRoll * -1
            end
        end

        if pose ~= "fist" then -- Reset call
            resetFist()
        end
    end
end

function onPeriodic()
    -- Lock after inactivity

    currentRoll = myo.getRoll()
    if myo.getXDirection() == "towardElbow" then
        currentRoll = currentRoll * -1
    end

    if unlocked and fistMade then -- Moves page when fist is held and Myo is rotated
        extendUnlock()
        subtractive = currentRoll - referenceRoll
        if subtractive > 0.2  then
            scrollDown()
        elseif subtractive < -0.2 then
            scrollUp() 
        end
    end

end

function onForegroundWindowChange(app, title)
    return wantActive = string.match(title,"%- Imgur %-") or string.match(title,"%- Imgur")
end

function activeAppName()
    return "Imgur"
end

function onActiveChange(isActive)
    if not isActive then
        unlocked = false
    end
end
