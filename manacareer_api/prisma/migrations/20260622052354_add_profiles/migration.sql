-- CreateTable
CREATE TABLE "Profile" (
    "id" TEXT NOT NULL,
    "firebaseUid" TEXT NOT NULL,
    "email" TEXT NOT NULL,
    "fullName" TEXT NOT NULL,
    "photoUrl" TEXT,
    "phone" TEXT,
    "dateOfBirth" TEXT,
    "gender" TEXT,
    "district" TEXT,
    "mandal" TEXT,
    "village" TEXT,
    "collegeName" TEXT,
    "collegeOther" TEXT,
    "branch" TEXT,
    "yearOfPassing" TEXT,
    "cgpa" TEXT,
    "currentStatus" TEXT,
    "skills" TEXT[],
    "resumeUrl" TEXT,
    "linkedinUrl" TEXT,
    "desiredRole" TEXT,
    "expectedSalary" TEXT,
    "profileComplete" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Profile_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "Profile_firebaseUid_key" ON "Profile"("firebaseUid");
