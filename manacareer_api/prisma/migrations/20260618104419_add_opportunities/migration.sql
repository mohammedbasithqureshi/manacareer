-- CreateTable
CREATE TABLE "Opportunity" (
    "id" TEXT NOT NULL,
    "title" TEXT NOT NULL,
    "org" TEXT NOT NULL,
    "type" TEXT NOT NULL,
    "district" TEXT NOT NULL,
    "location" TEXT NOT NULL,
    "money" TEXT NOT NULL,
    "deadline" TEXT NOT NULL,
    "urgent" BOOLEAN NOT NULL DEFAULT false,
    "about" TEXT NOT NULL,
    "eligibility" TEXT[],
    "applyInfo" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "Opportunity_pkey" PRIMARY KEY ("id")
);
